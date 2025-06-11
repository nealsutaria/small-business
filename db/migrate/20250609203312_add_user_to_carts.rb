class AddUserToCarts < ActiveRecord::Migration[7.1]
  def change
    add_reference :carts, :user, null: true, foreign_key: true
  end
end
