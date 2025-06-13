class AddColorAndSizeToCartItems < ActiveRecord::Migration[7.1]
  def change
    add_column :cart_items, :color, :string
    add_column :cart_items, :size, :string
  end
end
