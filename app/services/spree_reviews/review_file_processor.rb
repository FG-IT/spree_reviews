module SpreeReviews
  class CVSHeaderInvalidError < ::StandardError; end

  class ReviewFileProcessor
    class << self
      def process(file_path, product_id)
        product = Spree::Product.find(product_id)
        headers = []
        records = []
        CSV.foreach(file_path, encoding: "bom|utf-8").with_index do |row, i|
          if i == 0
            headers = row
            # raise CVSHeaderInvalidError.new('headers not valid') unless valid?(headers)
          else
            data = headers.zip(row).to_h
            record = data_to_record(data)
            contains_amazon = record.values.any? { |v| v.to_s.downcase.include?("amazon") }
            unless contains_amazon
              record[:product_id] = product_id
              records.push(record) if record_valid?(record)
            end
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

      COLUMN_ALIASES = {
        date: ["review_date", "date", "reviewDate", "Review Date","Date"],
        reviewer: ["reviewer", "profileName", "Author Name"],
        title: %w[Title review_title title],
        review: %w[review_text text Content],
        rating: %w[rating Rating],
        helpful: ["helpful", "helpful_vote", "Helpful Count"]
      }

      def find_column(row, aliases)
        aliases.each do |name|
          return name if row.keys.include?(name)
        end
        nil
      end

      def data_to_record(data)
        date_col = find_column(data, COLUMN_ALIASES[:date])
        reviewer_col = find_column(data, COLUMN_ALIASES[:reviewer])
        rating_col = find_column(data, COLUMN_ALIASES[:rating])
        title_col = find_column(data, COLUMN_ALIASES[:title])
        text_col = find_column(data, COLUMN_ALIASES[:review])
        helpful_col = find_column(data, COLUMN_ALIASES[:helpful])

        created_at = Date.parse(data[date_col]) + (rand(24 * 60 * 60)).seconds
        row = {
          name: data[reviewer_col] || 'Anonymous',
          rating: data[rating_col].to_i,
          title: data[title_col],
          review: data[text_col],
          approved: true,
          created_at: created_at,
          updated_at: created_at,
          verified_purchase: true,
          helpful_count: data[helpful_col]&.to_i || 0
        }
        row
      end

      def valid?(headers)
        required_headers = Set.new(COLUMN_ALIASES.values.flatten)
        required_headers.subset?(headers.to_set)
      end

      def record_valid?(record)
        record[:rating] >= 3 && record[:name].present? && (record[:title] || record[:review]).present?
      end
    end
  end
end