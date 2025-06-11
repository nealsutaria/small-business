class CreatePurchases < ActiveRecord::Migration[7.1]
  def change
    create_table :purchases do |t|
      t.references :user, null: false, foreign_key: true
      t.string :stripe_checkout_id
      t.integer :amount_total
      t.text :product_names

      t.timestamps
    end
  end
end
