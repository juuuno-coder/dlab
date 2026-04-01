class RestoreAllOriginalImages < ActiveRecord::Migration[7.1]
  def up
    # db/seeds.rb에 정의된 전체 템플릿 데이터 (로컬 이미지 경로 포함)
    # 스크린샷에서 깨진 이미지들(Cozy Stay, The Avenue 등)을 포함한 전체 목록
    templates = [
      { title: "LUMIER", image_url: "/images/templates/beauty_makeup.png" },
      { title: "溫 (ON)", image_url: "/images/templates/dining_omakase.png" },
      { title: "Sculpt & Soul", image_url: "/images/templates/fitness_gym.png" },
      { title: "Focus Lab", image_url: "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=800" },
      { title: "Cozy Stay", image_url: "/images/templates/cozy_stay.png" },
      { title: "The Avenue", image_url: "/images/templates/the_avenue.png" },
      { title: "Novus", image_url: "/images/templates/novus_saas.png" },
      { title: "Daily Crumb", image_url: "/images/templates/cafe_baguette.png" },
      { title: "SweetSpot", image_url: "/images/templates/sweetspot_donut.png" },
      { title: "SaladGreen", image_url: "/images/templates/salad_green.png" },
      { title: "ARCHIVE", image_url: "/images/templates/portfolio_gallery.png" },
      { title: "Pure Clinic", image_url: "/images/templates/skin_clinic_hero.png" },
      { title: "법무법인 정의", image_url: "/images/templates/justice_law.png" },
      { title: "Grand Hotel", image_url: "/images/templates/hotel_grand.png" },
      { title: "클린 싹싹", image_url: "/images/templates/cleaning_main.png" },
      { title: "Flower & Garden", image_url: "/images/templates/flower_garden.png" },
      { title: "Rent-All", image_url: "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?q=80&w=800" },
      { title: "Invest Future", image_url: "/images/templates/finance_invest.png" },
      { title: "Code Academy", image_url: "/images/templates/code_academy.png" },
      { title: "Little Star", image_url: "/images/templates/little_star.png" },
      { title: "Dental Care", image_url: "https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?q=80&w=800" },
      { title: "Happy Vet", image_url: "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=800" },
      { title: "Tax Partner", image_url: "/images/templates/tax_partner.png" },
      { title: "Wild Camp", image_url: "/images/templates/camping_tent.png" },
      { title: "Minimal Studio", image_url: "/images/templates/minimal_studio.png" },
      { title: "Urban Kicks", image_url: "/images/templates/urban_kicks.png" },
      { title: "L'Atelier", image_url: "/images/templates/leather_atelier.png" },
      { title: "Yoga Flow", image_url: "/images/templates/yoga_flow.png" }
    ]

    templates.each do |t|
      # 제목으로 찾기
      template = DesignTemplate.where("title LIKE ?", "%#{t[:title]}%").first
      if template
        # 1. ActiveStorage 연결 강제 해제 (Purge)
        begin
          template.pc_image.purge if template.pc_image.attached?
          template.mobile_image.purge if template.mobile_image.attached?
        rescue => e
          puts "Failed to purge #{template.title}: #{e.message}"
        end
        
        # 2. image_url 복구
        template.update_columns(image_url: t[:image_url])
        puts "Fully Restored: #{template.title}"
      end
    end
  end
end
