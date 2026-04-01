class SetPersistentTemplateImages < ActiveRecord::Migration[8.1]
  class DesignTemplate < ActiveRecord::Base; end

  def up
    # Map of preview_url => image_path (local or unsplash)
    
    # 1. Local Assets (Generated/Copied)
    local_images = {
      "/templates/beauty" => "/images/templates/beauty_makeup.png",
      "/templates/cafe" => "/images/templates/cafe_baguette.png",
      "/templates/cleaning" => "/images/templates/cleaning_main.png",
      "/templates/flower" => "/images/templates/flower_shop_hero_1.png",
      "/templates/pension" => "/images/templates/pension_spa.png",
      "/templates/shopping" => "/images/templates/shopping_new_arrivals.png",
      "/templates/medical" => "/images/templates/skin_clinic_hero.png"
    }

    # 2. Unsplash Fallbacks (for those without local assets yet)
    unsplash_images = {
      "/templates/rental" => "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?q=80&w=800",
      "/templates/hotel" => "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?q=80&w=800",
      "/templates/gym" => "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=800",
      "/templates/academy" => "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?q=80&w=800",
      "/templates/kinder" => "https://images.unsplash.com/photo-1587654780291-39c9404d746b?q=80&w=800",
      "/templates/finance" => "https://images.unsplash.com/photo-1460925895917-afdab827c52f?q=80&w=800",
      "/templates/burger" => "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=800",
      "/templates/cloth" => "https://images.unsplash.com/photo-1441986300917-64674bd600d8?q=80&w=800",
      "/templates/shoe" => "https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=800",
      "/templates/bag" => "https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=800", 
      "/templates/camping" => "https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?q=80&w=800",
      "/templates/dental" => "https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?q=80&w=800",
      "/templates/vet" => "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=800",
      "/templates/law" => "https://images.unsplash.com/photo-1589829085413-56de8ae18c73?q=80&w=800",
      "/templates/tax" => "https://images.unsplash.com/photo-1554224155-984063584d45?q=80&w=800",
      "/templates/consulting" => "https://images.unsplash.com/photo-1600880292203-757bb62b4baf?q=80&w=800"
    }

    # Apply Updates
    local_images.merge(unsplash_images).each do |preview_url, image_url|
      template = DesignTemplate.find_by(preview_url: preview_url)
      if template
        puts "Updating #{template.title} with image: #{image_url}"
        template.update_column(:image_url, image_url)
      end
    end
  end
end
