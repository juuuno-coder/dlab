class AddPriceToDesignTemplates < ActiveRecord::Migration[8.1]
  def change
    add_column :design_templates, :price, :integer, default: 0
  end
end
