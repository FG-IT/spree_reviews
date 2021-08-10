class AddReviewSummaryToSpreeProducts < ActiveRecord::Migration[6.1]
  def change
    if table_exists?('products')
      add_column :products, :rating_summary, :string, default: nil, null: true
    elsif table_exists?('spree_products')
      add_column :spree_products, :rating_summary, :string, default: nil, null: true
    end
  end
end
