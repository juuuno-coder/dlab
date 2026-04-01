class CreateDesignTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :design_templates do |t|
      t.string :title
      t.text :description
      t.string :category
      t.timestamps
    end
  end
end
