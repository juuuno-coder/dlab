class UpdateBeautyTemplateUrls < ActiveRecord::Migration[8.1]
  class DesignTemplate < ActiveRecord::Base; end

  def up
    nail = DesignTemplate.find_by(title: "Nail Artistry")
    nail&.update(preview_url: "/templates/nail", category: "beauty")

    barber = DesignTemplate.find_by(title: "Barber Classic")
    barber&.update(preview_url: "/templates/barber", category: "beauty")

    flower = DesignTemplate.find_by(title: "Flower & Garden")
    flower&.update(preview_url: "/templates/flower", category: "shopping") # Keep as shopping or portfolio
  end
end
