class AddMissingColumnsToDesignTemplates < ActiveRecord::Migration[8.1]
  def change
    add_column :design_templates, :preview_url, :string unless column_exists?(:design_templates, :preview_url)
    add_column :design_templates, :image_url, :string unless column_exists?(:design_templates, :image_url)
    add_column :design_templates, :is_featured, :boolean, default: false unless column_exists?(:design_templates, :is_featured)
    add_column :design_templates, :view_count, :integer, default: 0 unless column_exists?(:design_templates, :view_count)
  end
end
