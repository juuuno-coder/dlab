class AddMobileImageUrlToDesignTemplates < ActiveRecord::Migration[8.1]
  def change
    add_column :design_templates, :mobile_image_url, :string unless column_exists?(:design_templates, :mobile_image_url)
  end
end
