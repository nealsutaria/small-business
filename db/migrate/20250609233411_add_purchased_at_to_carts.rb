class AddPurchasedAtToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :purchased_at, :datetime
  end
end
