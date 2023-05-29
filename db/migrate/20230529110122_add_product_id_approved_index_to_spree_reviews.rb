class AddProductIdApprovedIndexToSpreeReviews < ActiveRecord::Migration[6.1]
  def up
    if table_exists?('spree_reviews')
      add_index :spree_reviews, [:product_id, :approved], name: 'index_spree_reviews_on_product_id_and_approved'
    end
  end

  def down
    if table_exists?('spree_reviews')
      remove_index :spree_reviews, column: [:product_id, :approved], name: 'index_spree_reviews_on_product_id_and_approved'
    end
  end
end
