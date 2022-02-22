# Generate a single file
module SpreeReviews
  class GoogleReviewFeedGenerator
    def initialize(filename, scope)
      @filename = filename
      @scope = scope
      @doc = Ox::Document.new
      add_instruct
      add_feed
      add_publisher
      add_reviews
    end

    def generate()
      @scope.find_each do |review|
        review_decor = ReviewDecorator.new(review)
        @reviews << review_decor.to_review_xml
      end
      xml = Ox.dump(@doc)
      File.write(@filename, xml, mode: 'wb+')
    end

    def add_instruct
      instruct = Ox::Instruct.new(:xml)
      instruct[:version] = '1.0'
      instruct[:encoding] = 'UTF-8'
      @doc << instruct
    end

    def add_feed
      feed = <<-FEED
        <feed 
          xmlns:vc="http://www.w3.org/2007/XMLSchema-versioning"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:noNamespaceSchemaLocation="http://www.google.com/shopping/reviews/schema/product/2.3/product_reviews.xsd">
          
        </feed>
      FEED
      @feed = Ox::Element.new('feed')
      @feed['xmlns:vc'] = 'http://www.w3.org/2007/XMLSchema-versioning'
      @feed['xmlns:xsi'] = 'http://www.w3.org/2001/XMLSchema-instance'
      @feed['xsi:noNamespaceSchemaLocation'] = 'http://www.google.com/shopping/reviews/schema/product/2.3/product_reviews.xsd'
      @feed << Ox::Raw.new('<version>2.3</version>')
      @doc << @feed
    end

    def add_reviews
      @reviews = Ox::Element.new('reviews')
      @feed << @reviews
    end

    def add_publisher
      @feed << Ox::Raw.new("<publisher><name>Everymarket</name></publisher>")
    end

  end
end