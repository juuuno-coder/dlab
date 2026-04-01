class AddProposalFieldsToBiddings < ActiveRecord::Migration[7.2]
  def change
    add_column :biddings, :analysis_notes, :text
    add_column :biddings, :proposal_outline, :text
    add_column :biddings, :winning_strategy, :text
  end
end
