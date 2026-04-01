class CreateQuotes < ActiveRecord::Migration[8.1]
  def change
    create_table :quotes do |t|
      t.string :company_name
      t.string :contact_name
      t.string :email
      t.string :phone
      t.string :project_type
      t.string :budget
      t.text :message
      t.string :status

      t.timestamps
    end
  end
end
