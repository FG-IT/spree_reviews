require 'json'
module ::SpreeReview::Spree::ProductDecorator
  def self.prepended(base)
    base.has_many :reviews
    base.has_many :product_reviews, class_name: 'Spree::Review'
  end


  def stars
    (avg_rating * 10).try(:round) / 10.0 || 0
  end

  def recalculate_rating
    self[:reviews_count] = reviews.reload.approved.count
    if reviews_count > 0
      summary = {}
      reviews.approved.group_by(&:rating).each do |rating, rreviews|
        summary[rating] = rreviews.count
      end
      self[:rating_summary] = summary.to_json
      self[:avg_rating] = reviews.approved.sum(:rating).to_f / reviews_count
    else
      self[:avg_rating] = 0
    end
    save
  end

end

::Spree::Product.prepend ::SpreeReview::Spree::ProductDecorator
