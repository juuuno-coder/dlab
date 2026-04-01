class UpdateCafeEducationTemplateUrls < ActiveRecord::Migration[8.1]
  class DesignTemplate < ActiveRecord::Base; end

  def up
    # Cafe
    crumb = DesignTemplate.find_by(title: "Daily Crumb")
    crumb&.update(preview_url: "/templates/cafe", category: "cafe") # Should already be cafe, but ensuring

    sweet = DesignTemplate.find_by(title: "Sweet Spot")
    sweet&.update(preview_url: "/templates/dessert", category: "cafe")

    # Education
    kinder = DesignTemplate.find_by(title: "English Kinder")
    kinder&.update(preview_url: "/templates/kinder", category: "academy")
    
    code = DesignTemplate.find_by(title: "Code Academy")
    code&.update(preview_url: "/templates/academy", category: "academy")
  end
end
