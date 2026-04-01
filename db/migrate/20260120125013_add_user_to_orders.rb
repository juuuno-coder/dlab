class AddUserToOrders < ActiveRecord::Migration[8.1]
  def change
    add_reference :orders, :user, null: false, foreign_key: true
    add_column :orders, :total_amount, :decimal
  end
end
