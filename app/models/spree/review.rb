class Spree::Review < ActiveRecord::Base
  belongs_to :product, touch: true
  belongs_to :user, class_name: Spree.user_class.to_s
  has_many :feedback_reviews
  has_many_attached :images
  after_save :recalculate_product_rating, if: :approved?
  after_destroy :recalculate_product_rating

  validates :name, :review, presence: true
  validates :rating, numericality: {
      only_integer: true,
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: 5,
      message: Spree.t(:you_must_enter_value_for_rating)
  }

  default_scope { order('spree_reviews.created_at DESC') }

  scope :localized, ->(lc) { where('spree_reviews.locale = ?', lc) }
  scope :most_recent_first, -> { order('spree_reviews.created_at DESC') }
  scope :oldest_first, -> { reorder('spree_reviews.created_at ASC') }
  scope :highest_rating_first, -> { reorder('spree_reviews.rating DESC') }
  scope :most_helpful_first, -> { reorder('spree_reviews.helpful_count DESC') }
  scope :preview, -> { limit(Spree::Reviews::Config[:preview_size]).oldest_first }
  scope :approved, -> { where(approved: true) }
  scope :has_photo, -> { joins(:images_attachments) }
  scope :rating_filter, ->(rating) { where(rating: rating) }
  scope :not_approved, -> { where(approved: false) }
  scope :default_approval_filter, -> { Spree::Reviews::Config[:include_unapproved_reviews] ? all : approved }

  def self.ransackable_attributes(auth_object = nil)
    ["approved", "created_at", "helpful_count", "id", "id_value", "ip_address", "locale", "location", "name", "product_id", "rating", "review", "review_id", "show_identifier", "title", "updated_at", "user_id", "verified_purchase"]
  end

  def feedback_stars
    return 0 if feedback_reviews.size <= 0
    ((feedback_reviews.sum(:rating) / feedback_reviews.size) + 0.5).floor
  end

  def recalculate_product_rating
    product.recalculate_rating if product.present?
  end
end
