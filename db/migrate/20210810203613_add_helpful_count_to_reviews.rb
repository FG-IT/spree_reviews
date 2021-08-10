class AddHelpfulCountToReviews < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_reviews, :helpful_count, :integer, default: 0, null: false
  end
end
