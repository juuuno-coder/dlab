class AddPreferredDomainToQuotes < ActiveRecord::Migration[8.1]
  def change
    add_column :quotes, :preferred_domain, :string
  end
end
