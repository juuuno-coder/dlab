class CreateBiddings < ActiveRecord::Migration[7.2]
  def change
    create_table :biddings do |t|
      t.string :title, null: false
      t.string :agency
      t.string :application_period
      t.string :budget
      t.string :status, default: "예정"
      t.integer :progress, default: 0
      t.string :assignee
      t.text :description
      t.date :deadline
      t.string :partner, default: "리멘(Limen)"

      t.timestamps
    end

    add_index :biddings, :status
    add_index :biddings, :deadline
  end
end
