class FixTemplateImagesAndContent < ActiveRecord::Migration[8.1]
  class DesignTemplate < ActiveRecord::Base; end

  def up
    # 1. Fix Broken Images
    burger = DesignTemplate.find_by(title: "Burger House")
    if burger
      burger.update(image_url: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=800")
      puts "Fixed Burger House image"
    end
    
    flower = DesignTemplate.find_by(title: "Flower & Garden")
    if flower
      flower.update(image_url: "https://images.unsplash.com/photo-1490750967868-58cb75069ed6?q=80&w=800")
      puts "Fixed Flower & Garden image"
    end

    yoga = DesignTemplate.find_by(title: "Yoga Flow")
    if yoga
      yoga.update(image_url: "https://images.unsplash.com/photo-1544367563-121910aa662f?q=80&w=800")
      puts "Fixed Yoga Flow image"
    end
    
    # 2. Fix Content & Reduce Duplication
    accounting = DesignTemplate.find_by(title: "Accounting Plus")
    if accounting
      accounting.update(
        description: "회계법인 및 세무사를 위한 전문 템플릿. 복잡한 데이터를 명확한 차트와 표로 전달하는 신뢰 중심 디자인.",
        category: "law" # Move to Law category for better distribution
      )
      puts "Updated Accounting Plus"
    end
    
    # Ensure Consulting Hub points to the new template
    consulting = DesignTemplate.find_by(title: "Consulting Hub")
    if consulting
      consulting.update(
        preview_url: "/templates/consulting",
        category: "corporate"
      )
      puts "Updated Consulting Hub"
    end
    
    # Ensure Marketing Agency points to the new template
    agency = DesignTemplate.find_by(title: "Marketing Agency")
    if agency
      agency.update(
        preview_url: "/templates/agency",
        category: "corporate"
      )
      puts "Updated Marketing Agency"
    end
  end
  
  def down
    # Irreversible specific content updates, but generally safe to leave as is.
  end
end
