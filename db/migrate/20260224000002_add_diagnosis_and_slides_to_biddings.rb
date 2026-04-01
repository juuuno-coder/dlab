class AddDiagnosisAndSlidesToBiddings < ActiveRecord::Migration[7.2]
  def change
    add_column :biddings, :diagnosis_report, :text
    add_column :biddings, :slides_html, :text
  end
end
