class UpdateMedicalLawTemplateUrls < ActiveRecord::Migration[8.1]
  class DesignTemplate < ActiveRecord::Base; end

  def up
    dental = DesignTemplate.find_by(title: "Dental Care")
    dental&.update(preview_url: "/templates/dental", category: "medical")

    vet = DesignTemplate.find_by(title: "Pet Hospital")
    vet&.update(preview_url: "/templates/vet", category: "medical")

    tax = DesignTemplate.find_by(title: "Tax Pro")
    tax&.update(preview_url: "/templates/tax", category: "law") # Categorize as Law/Professional

    # Ensure Trust & Logic points to law content (assuming generic law template exists)
    law = DesignTemplate.find_by(title: "Trust & Logic")
    law&.update(preview_url: "/templates/law", category: "law")
    
    # Ensure Pure Clinic points to medical content
    clinic = DesignTemplate.find_by(title: "Pure Clinic")
    clinic&.update(preview_url: "/templates/medical", category: "medical")
  end
end
