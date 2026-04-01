class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders, if_not_exists: true do |t|
      t.references :product, null: false, foreign_key: true
      t.string :customer_name
      t.integer :amount
      t.string :status
      t.string :payment_key
      t.string :order_uid

      t.timestamps
    end
  end
end
