class CreateAgencies < ActiveRecord::Migration[8.1]
  def change
    create_table :agencies do |t|
      t.string :name, null: false
      t.string :subdomain, null: false
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.text :settings
      t.boolean :active, default: true

      t.timestamps
    end
    add_index :agencies, :subdomain, unique: true
  end
end
