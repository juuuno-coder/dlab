class AddTemplateSettingsToBiddings < ActiveRecord::Migration[7.2]
  def change
    add_column :biddings, :selected_template_ids, :text
    add_column :biddings, :slide_theme_color, :string, default: '#1E40AF'
    add_column :biddings, :slide_font_family, :string, default: 'Pretendard'
  end
end
