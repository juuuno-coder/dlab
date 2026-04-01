class UpdateShoppingTemplateUrls < ActiveRecord::Migration[8.1]
  class DesignTemplate < ActiveRecord::Base; end

  def up
    pet = DesignTemplate.find_by(title: "Pet Palace")
    pet&.update(preview_url: "/templates/petshop", category: "shopping")

    shop = DesignTemplate.find_by(title: "AETHER")
    shop&.update(preview_url: "/templates/shop", category: "shopping") # Ensure AETHER is correct
  end
end
