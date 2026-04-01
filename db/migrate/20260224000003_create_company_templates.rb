class CreateCompanyTemplates < ActiveRecord::Migration[7.2]
  def change
    create_table :company_templates do |t|
      t.string :name, null: false
      t.string :template_type, null: false # 'company_intro', 'history', 'organization', 'ceo_message', 'portfolio'
      t.text :content
      t.text :html_content
      t.integer :order, default: 0
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :company_templates, :template_type
    add_index :company_templates, :active
  end
end
