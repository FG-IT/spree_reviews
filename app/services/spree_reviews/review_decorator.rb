module SpreeReviews
  class ReviewDecorator
    def initialize(review)
      @review = review
    end

    def to_review_xml
      review = Ox::Element.new('review')
      review << reviewer
      review << review_timestamp
      review << title if @review.title.present?
      review << content
      review << review_url
      review << ratings
      review << products
      review
    end

    def reviewer
      Ox::Raw.new("<reviewer><name>#{@review.name.encode(xml: :attr) || 'Anonymous'}</name></reviewer>")
    end

    def title
      Ox::Raw.new("<title>#{@review.title&.encode(xml: :attr)}</title>")
    end

    def content
      Ox::Raw.new("<content>#{@review.review&.encode(xml: :attr)}</content>")
    end

    def review_timestamp
      Ox::Raw.new("<review_timestamp>#{@review.created_at.to_formatted_s(:iso8601)}</review_timestamp>")
    end

    def review_url
      Ox::Raw.new('<review_url type="singleton">' + review_link + '</review_url>')
    end

    def ratings
      Ox::Raw.new("<ratings><overall min=\"1\" max=\"5\">#{@review.rating}</overall></ratings>")
    end

    def products 
      ps = Ox::Element.new('products')
      ps << product
      ps
    end

    def product
      pdt = @review.product
      p = Ox::Element.new('product')
      p << Ox::Raw.new("<product_name>#{pdt.title&.encode(xml: :attr)}</product_name>")
      p << Ox::Raw.new("<product_url>#{product_link(pdt)}</product_url>")
      p
    end

    def product_link(product)
      website_link + Spree::Core::Engine.routes.url_helpers.product_path(product)
    end

    def review_link
      website_link + Spree::Core::Engine.routes.url_helpers.review_path(@review)
    end

    def website_link
      url = default_store_url
      url = 'https://' + url if !url.starts_with?('http')
      url.chomp! if url.ends_with?('/')
      url
    end

    def default_store_url
      Thread.current[:default_store_url] ||= Spree::Store.default.url
    end
  end
end