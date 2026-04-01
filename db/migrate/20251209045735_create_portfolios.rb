class CreatePortfolios < ActiveRecord::Migration[8.1]
  def change
    create_table :portfolios do |t|
      t.string :title
      t.text :description
      t.string :client
      t.string :image_url
      t.date :project_date
      t.string :category

      t.timestamps
    end
  end
end
