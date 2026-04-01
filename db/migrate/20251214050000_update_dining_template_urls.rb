class UpdateDiningTemplateUrls < ActiveRecord::Migration[8.1]
  class DesignTemplate < ActiveRecord::Base; end

  def up
    burger = DesignTemplate.find_by(title: "Burger House")
    burger&.update(preview_url: "/templates/burger", category: "dining")

    wine = DesignTemplate.find_by(title: "Wine Social")
    wine&.update(preview_url: "/templates/wine", category: "dining")
    
    salad = DesignTemplate.find_by(title: "Salad Green")
    salad&.update(preview_url: "/templates/salad", category: "dining") 
  end
end
