class AddVerifiedPurchaseToReviews < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_reviews, :verified_purchase, :boolean, default: true
    add_index :spree_reviews, :verified_purchase
  end
end
