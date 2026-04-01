class AddPresentationScriptToBiddings < ActiveRecord::Migration[7.2]
  def change
    add_column :biddings, :presentation_script, :text
    add_column :biddings, :proposal_content, :text
    add_column :biddings, :rfp_content, :text
    add_column :biddings, :task_order_content, :text
  end
end
