class AddPreviewUrlToPortfolios < ActiveRecord::Migration[8.1]
  def change
    add_column :portfolios, :preview_url, :string
  end
end
