class FinalizeTemplates < ActiveRecord::Migration[8.1]
  class DesignTemplate < ActiveRecord::Base; end

  def up
    # 1. Shopping -> Fashion Multi-Shop 업데이트 (기존 'Pet Palace'는 별도 파일로 분리됨)
    shopping = DesignTemplate.find_by(preview_url: '/templates/shopping')
    if shopping
      shopping.update(
        title: "The Avenue",
        description: "Modern fashion multi-shop with curated collections.",
        category: "shopping"
      )
    else
      DesignTemplate.create(
        title: "The Avenue",
        description: "Modern fashion multi-shop with curated collections.",
        preview_url: "/templates/shopping",
        category: "shopping"
      )
    end

    # 2. Academy, Kinder, Rental, Finance, Medical, Dental, Vet, Law, Tax, Hotel, Pension, Camping, Cloth, Shoe, Bag 설명 업데이트 및 확보
    updates = [
      { url: "/templates/academy", title: "Code Academy", desc: "Online coding education platform with roadmap." },
      { url: "/templates/kinder", title: "Little Star", desc: "Cute and playful English kindergarten website." },
      { url: "/templates/rental", title: "Rent-All", desc: "Premium car rental service with booking system." },
      { url: "/templates/finance", title: "Invest Future", desc: "Professional asset management and consulting firm." },
      { url: "/templates/medical", title: "Pure Clinic", desc: "Dermatology clinic with procedure information." },
      { url: "/templates/dental", title: "Gentle Dental", desc: "Comfortable and trustworthy dental clinic." },
      { url: "/templates/vet", title: "Happy Vet", desc: "24h animal medical center with friendly design." },
      { url: "/templates/law", title: "Justice Law", desc: "Reliable law firm with practice area showcase." },
      { url: "/templates/tax", title: "Tax Partner", desc: "Smart tax advisor with calculation tools." },
      { url: "/templates/hotel", title: "Grand Hotel", desc: "Luxury hotel booking with suite showcase." },
      { url: "/templates/pension", title: "Cozy Stay", desc: "Emotional private pension booking." },
      { url: "/templates/camping", title: "Wild Camp", desc: "Outdoor camping gear rental and site booking." },
      { url: "/templates/cloth", title: "Minimal Studio", desc: "Minimalist fashion brand online store." },
      { url: "/templates/shoe", title: "Urban Kicks", desc: "Street style sneaker shop with drops." },
      { url: "/templates/bag", title: "L'Atelier", desc: "Handcrafted leather bag atelier shop." }
    ]

    updates.each do |u|
      t = DesignTemplate.find_or_initialize_by(preview_url: u[:url])
      t.update(title: u[:title], description: u[:desc])
    end
  end
end
