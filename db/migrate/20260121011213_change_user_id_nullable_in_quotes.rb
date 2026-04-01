class ChangeUserIdNullableInQuotes < ActiveRecord::Migration[8.1]
  def change
    change_column_null :quotes, :user_id, true
  end
end
