class AddUserAndSessionToQuotes < ActiveRecord::Migration[8.1]
  def change
    add_reference :quotes, :user, null: true, foreign_key: true
    add_column :quotes, :guest_session_id, :string
  end
end
