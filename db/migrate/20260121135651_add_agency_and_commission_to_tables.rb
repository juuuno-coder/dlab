class AddAgencyAndCommissionToTables < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :agency, foreign_key: true, null: true
    add_reference :orders, :agency, foreign_key: true, null: true
    
    add_column :agencies, :commission_rate, :decimal, precision: 5, scale: 2, default: 10.0 # 10.00%
    add_column :orders, :commission_amount, :decimal, precision: 10, scale: 2, default: 0
  end
end
