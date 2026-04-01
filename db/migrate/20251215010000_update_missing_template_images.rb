class UpdateMissingTemplateImages < ActiveRecord::Migration[8.1]
  class DesignTemplate < ActiveRecord::Base; end

  def up
    # Map of preview_url => new local image path
    updates = {
      "/templates/dining" => "/images/templates/dining_omakase.png",
      "/templates/gym" => "/images/templates/fitness_gym.png",
      "/templates/hotel" => "/images/templates/hotel_luxury.png",
      "/templates/law" => "/images/templates/law_office.png",
      "/templates/camping" => "/images/templates/camping_tent.png",
      "/templates/academy" => "/images/templates/academy_coding.png",
      "/templates/kinder" => "/images/templates/kinder_classroom.png",
      "/templates/corporate" => "/images/templates/corporate_office.png",
      "/templates/portfolio" => "/images/templates/portfolio_gallery.png",
      "/templates/finance" => "/images/templates/finance_invest.png",
      # Tax uses Law image as fallback for now or keep Unsplash if not generated
      "/templates/tax" => "/images/templates/law_office.png",
      # Startup uses corporate
      "/templates/startup" => "/images/templates/corporate_office.png"
    }

    updates.each do |preview_url, image_url|
      template = DesignTemplate.find_by(preview_url: preview_url)
      if template
        puts "Updating image for #{template.title} (#{preview_url})"
        template.update(image_url: image_url)
      end
    end
  end
end
