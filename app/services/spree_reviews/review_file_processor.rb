module SpreeReviews
  class CVSHeaderInvalidError < ::StandardError; end
  class ReviewFileProcessor
    class << self
      def process(file_path, product_id)
        product = Spree::Product.find(product_id)
        headers = []
        records = []
        CSV.foreach(file_path).with_index do |row, i|
          if i == 0
            headers = row
            raise CVSHeaderInvalidError.new('headers not valid') unless valid?(headers)
          else
            data = headers.zip(row).to_h
            record = data_to_record(data)
            record[:product_id] = product_id
            records.push(record) if record[:rating] > 3
          end
          if records.size == 100
            Spree::Review.insert_all(records)
            records = []
          end
        end
        Spree::Review.insert_all(records) if records.size > 0
        product.recalculate_rating
      end

      private 
        def data_to_record(data)
          created_at = DateTime.strptime(data['review_date'], "%m/%d/%Y") + (rand(24 * 60 * 60)).seconds
          {
            name: data['reviewer'],
            rating: data['rating'].to_i,
            title: data['review_title'],
            review: data['review_text'],
            approved: true,
            created_at: created_at,
            updated_at: created_at,
            verified_purchase: true,
            helpful_count: data['helpful_vote']&.to_i || 0 
          }
        end

        def valid?(headers)
          required_headers = Set.new(['rating', 'review_title', 'review_text', 'review_date', 'reviewer'])
          required_headers.subset?(headers.to_set)
        end
    end
  end
end