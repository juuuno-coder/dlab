class UpdateCorporateTemplateUrls < ActiveRecord::Migration[8.1]
  class DesignTemplate < ActiveRecord::Base; end

  def up
    agency = DesignTemplate.find_by(title: "Marketing Agency")
    if agency
      agency.update(preview_url: "/templates/agency")
      puts "Updated Marketing Agency URL"
    end

    consulting = DesignTemplate.find_by(title: "Consulting Hub")
    if consulting
      consulting.update(preview_url: "/templates/consulting")
      puts "Updated Consulting Hub URL"
    end
    
    accounting = DesignTemplate.find_by(title: "Accounting Plus")
    if accounting
      accounting.update(preview_url: "/templates/consulting")
      puts "Updated Accounting Plus URL"
    end

    # Merged from duplicate migration
    novus = DesignTemplate.find_by(title: "Novus")
    novus&.update(preview_url: "/templates/startup", category: "corporate")

    rent = DesignTemplate.find_by(title: "Rent-All")
    rent&.update(preview_url: "/templates/rental", category: "corporate")

    invest = DesignTemplate.find_by(title: "Invest Future")
    invest&.update(preview_url: "/templates/finance", category: "corporate")
  end
  
  def down
    DesignTemplate.where(title: ["Marketing Agency", "Consulting Hub", "Accounting Plus"]).update_all(preview_url: "/templates/corporate")
  end
end
