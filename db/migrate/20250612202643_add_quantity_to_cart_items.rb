class AddQuantityToCartItems < ActiveRecord::Migration[7.1]
  def change
    add_column :cart_items, :quantity, :integer, default: 1
  end
end
