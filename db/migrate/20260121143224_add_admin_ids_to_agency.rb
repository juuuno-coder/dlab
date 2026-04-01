class AddAdminIdsToAgency < ActiveRecord::Migration[8.1]
  def change
    add_column :agencies, :admin_ids, :text, default: "[]"
  end
end
