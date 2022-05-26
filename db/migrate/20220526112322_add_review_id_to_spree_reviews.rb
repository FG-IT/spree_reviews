class AddReviewIdToSpreeReviews < ActiveRecord::Migration[6.1]
  def change
    if table_exists?('spree_reviews')
      add_column :spree_reviews, :review_id, :string, default: nil, null: true
      add_index :spree_reviews, :review_id
    end
  end
end
