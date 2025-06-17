class AddProductDetailsToPurchases < ActiveRecord::Migration[7.1]
  def change
    add_column :purchases, :product_details, :text
  end
end
