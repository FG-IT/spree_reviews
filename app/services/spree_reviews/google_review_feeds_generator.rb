module SpreeReviews
  class GoogleReviewFeedsGenerator
    SINGLE_FILE_REVIEW_SIZE = 50_000
    BASE_DIR = Rails.root.join('storage')
    FILE_PREFIX = 'google_product_review_'

    def self.run
      delete_old_files
      offset = 0
      file_count = 0
      while (true) do 
        q = Spree::Review.where.not(product_id: nil).includes({product: :variants_including_master}).offset(offset).limit(SINGLE_FILE_REVIEW_SIZE)
        filename = BASE_DIR.join("#{FILE_PREFIX}#{file_count}.xml")
        GoogleReviewFeedGenerator.new(filename, q).generate
        if q.size < SINGLE_FILE_REVIEW_SIZE
          break
        else
          offset += SINGLE_FILE_REVIEW_SIZE
          file_count += 1
        end
      end
      zip_files
    end

    def self.delete_old_files
      Dir.entries(BASE_DIR).each do |f|
        File.delete(BASE_DIR.join(f)) if f.starts_with?(FILE_PREFIX)
      end
    end

    def self.zip_files
      zip_file = BASE_DIR.join("#{FILE_PREFIX}all.zip")

      Zip::File.open(zip_file, create: true) do |zipfile|
        Dir.entries(BASE_DIR).each do |f|
          if f.starts_with?(FILE_PREFIX)
            zipfile.add(f, BASE_DIR.join(f))
          end
        end
      end
    end
  end
end