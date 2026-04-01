class AddDiamondScoreToDesignTemplates < ActiveRecord::Migration[8.1]
  def change
    add_column :design_templates, :diamond_score, :integer, default: 50
  end
end
