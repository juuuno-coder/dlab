class AddWorkflowStatusToQuotes < ActiveRecord::Migration[8.1]
  def change
    add_column :quotes, :workflow_status, :string, default: "received"
  end
end
