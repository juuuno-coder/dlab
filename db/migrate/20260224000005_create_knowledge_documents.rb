class CreateKnowledgeDocuments < ActiveRecord::Migration[7.2]
  def change
    create_table :knowledge_documents do |t|
      t.string :title, null: false
      t.string :category, null: false
      t.text :description
      t.text :analysis_result
      t.text :metadata
      t.datetime :analyzed_at
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :knowledge_documents, :category
    add_index :knowledge_documents, :active
  end
end
