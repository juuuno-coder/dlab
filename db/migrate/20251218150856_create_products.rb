class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products, if_not_exists: true do |t|
      t.string :name
      t.text :description
      t.integer :price
      t.integer :stock
      t.string :image_url

      t.timestamps
    end
  end
end
