class AddParentAgencyToAgencies < ActiveRecord::Migration[8.1]
  def change
    add_reference :agencies, :parent_agency, null: true, foreign_key: { to_table: :agencies }
  end
end
