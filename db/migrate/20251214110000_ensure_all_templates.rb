class EnsureAllTemplates < ActiveRecord::Migration[8.1]
  class DesignTemplate < ActiveRecord::Base; end

  def up
    templates = [
      # Fitness (3)
      { title: "Urban Fit", category: "fitness", preview_url: "/templates/gym", description: "High-energy gym template with neon accents and schedule booking." },
      { title: "Sculpt & Soul", category: "fitness", preview_url: "/templates/sculpt", description: "Elegant pilates studio design with soft earth tones." },
      { title: "Yoga Flow", category: "fitness", preview_url: "/templates/yoga", description: "Zen-inspired yoga template for mindfulness and balance." },
      
      # Beauty (4)
      { title: "LUMIER", category: "beauty", preview_url: "/templates/beauty", description: "Luxury beauty salon template with minimal aesthetics." },
      { title: "Nail Artistry", category: "beauty", preview_url: "/templates/nail", description: "Trendy nail salon design with pop colors and gallery." },
      { title: "Barber Classic", category: "beauty", preview_url: "/templates/barber", description: "Vintage barbershop style with gold and leather textures." },
      { title: "Flower & Garden", category: "beauty", preview_url: "/templates/flower", description: "Botanical florist portfolio with fresh imagery." },

      # Dining (6)
      { title: "溫 (ON)", category: "dining", preview_url: "/templates/dining", description: "Premium fine dining experience with dark moody vibes." },
      { title: "Burger House", category: "dining", preview_url: "/templates/burger", description: "American retro diner style with bold typography." },
      { title: "Wine Social", category: "dining", preview_url: "/templates/wine", description: "Sophisticated wine bar with parallax scrolling effects." },
      { title: "Salad Green", category: "dining", preview_url: "/templates/salad", description: "Fresh and organic salad bar with interactive bowl builder." },
      { title: "Daily Crumb", category: "cafe", preview_url: "/templates/cafe", description: "Warm and cozy bakery cafe with artisanal bread showcase." },
      { title: "Sweet Spot", category: "cafe", preview_url: "/templates/dessert", description: "Playful dessert cafe with pastel colors and donuts." },

      # Corporate (7)
      { title: "Marketing Agency", category: "corporate", preview_url: "/templates/agency", description: "Creative digital agency portfolio with gradients." },
      { title: "Consulting Hub", category: "corporate", preview_url: "/templates/consulting", description: "Professional consulting firm with trust-building layout." },
      { title: "Novus", category: "corporate", preview_url: "/templates/startup", description: "Modern SaaS startup landing page with dark mode." },
      { title: "Code Academy", category: "academy", preview_url: "/templates/academy", description: "Tech education platform with course curriculum UI." },
      { title: "English Kinder", category: "academy", preview_url: "/templates/kinder", description: "Kids education site with primary colors and fun shapes." },
      { title: "Rent-All", category: "corporate", preview_url: "/templates/rental", description: "Car rental service with vehicle search and booking." },
      { title: "Invest Future", category: "corporate", preview_url: "/templates/finance", description: "Financial asset management with data visualization." },

      # Medical & Law (5)
      { title: "Pure Clinic", category: "medical", preview_url: "/templates/medical", description: "High-end dermatology clinic with clean medical aesthetic." },
      { title: "Dental Care", category: "medical", preview_url: "/templates/dental", description: "Bright and friendly dental clinic with appointment UI." },
      { title: "Pet Hospital", category: "medical", preview_url: "/templates/vet", description: "Warm and caring veterinary hospital design." },
      { title: "Trust & Logic", category: "law", preview_url: "/templates/law", description: "Serious law firm presence with weighty typography." },
      { title: "Tax Pro", category: "law", preview_url: "/templates/tax", description: "Professional accounting service with tax calculator." },

      # Stay (4)
      { title: "Hanok Stay", category: "stay", preview_url: "/templates/stay", description: "Traditional Korean stay with serene atmosphere." },
      { title: "Camp Vibez", category: "stay", preview_url: "/templates/camping", description: "Outdoor glamping site with nature-inspired theme." },
      { title: "Focus Lab", category: "stay", preview_url: "/templates/studio", description: "Industrial creative studio and coworking space rental." },
      { title: "Clean Service", category: "stay", preview_url: "/templates/cleaning", description: "Professional cleaning service with booking form." },

      # Shopping (2)
      { title: "AETHER", category: "shopping", preview_url: "/templates/shop", description: "Minimalist fashion e-commerce grid." },
      { title: "Pet Palace", category: "shopping", preview_url: "/templates/petshop", description: "Cute pet supplies shop with mint and coral theme." }
    ]

    templates.each do |t|
      template = DesignTemplate.find_or_initialize_by(title: t[:title])
      template.update(
        category: t[:category],
        preview_url: t[:preview_url],
        description: t[:description]
      )
    end
  end
end
