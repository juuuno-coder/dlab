class UpdateTemplateImagesV2 < ActiveRecord::Migration[8.1]
  class DesignTemplate < ActiveRecord::Base; end

  def up
    # 새로운 PC 이미지로 템플릿 업데이트
    templates = [
      { 
        title: "LUMIER", 
        description: "청담동 하이엔드 살롱 스타일. 고급스러운 세리프 폰트와 인물 중심 레이아웃.", 
        category: "beauty", 
        preview_url: "/templates/beauty", 
        image_url: "/images/templates/beauty_makeup.png",
        is_featured: true 
      },
      { 
        title: "溫 (ON)", 
        description: "여백의 미를 살린 모던 오마카세 다이닝 스타일. 갤러리 같은 메뉴 소개 디자인.", 
        category: "dining", 
        preview_url: "/templates/dining", 
        image_url: "/images/templates/dining_omakase.png",
        is_featured: true 
      },
      { 
        title: "Sculpt & Soul", 
        description: "아티스틱 웰니스 브랜드 스타일. 감각적인 다크 모드와 타이포그래피.", 
        category: "fitness", 
        preview_url: "/templates/gym", 
        image_url: "/images/templates/fitness_gym.png",
        is_featured: false
      },
      { 
        title: "Yoga Flow", 
        description: "호흡이 머무는 곳, 현재. 요가 스튜디오를 위한 평온한 디자인.", 
        category: "fitness", 
        preview_url: "/templates/yoga", 
        image_url: "/images/templates/yoga_flow.png",
        is_featured: true
      },
      { 
        title: "Focus Lab", 
        description: "건축적인 조형미가 돋보이는 스터디 랩 스타일. 집중력을 높이는 미니멀리즘.", 
        category: "space", 
        preview_url: "/templates/study", 
        image_url: "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=800",
        is_featured: false
      },
      { 
        title: "Cozy Stay", 
        description: "제주의 숨은 보석. 바람이 머물고, 마음이 쉬어가는 곳.", 
        category: "stay", 
        preview_url: "/templates/pension", 
        image_url: "/images/templates/cozy_stay.png",
        is_featured: true 
      },
      { 
        title: "The Avenue", 
        description: "큐레이션이 돋보이는 모던 패션 멀티샵. 트렌디한 룩북 스타일.", 
        category: "shopping", 
        preview_url: "/templates/shopping", 
        image_url: "/images/templates/the_avenue.png",
        is_featured: true
      },
      { 
        title: "Novus", 
        description: "팀워크의 새로운 기준. 복잡한 프로젝트 관리부터 실시간 커뮤니케이션까지.", 
        category: "corporate", 
        preview_url: "/templates/startup", 
        image_url: "/images/templates/novus_saas.png",
        is_featured: false
      },
      { 
        title: "Daily Crumb", 
        description: "따뜻한 베이지톤의 감성 베이커리 스타일. 인스타그램 피드 연동 디자인.", 
        category: "cafe", 
        preview_url: "/templates/cafe", 
        image_url: "/images/templates/cafe_baguette.png",
        is_featured: false
      },
      { 
        title: "SweetSpot", 
        description: "Life is Sweet! 수제 도넛과 디저트의 달콤한 유혹.", 
        category: "cafe", 
        preview_url: "/templates/donut", 
        image_url: "/images/templates/sweetspot_donut.png",
        is_featured: true
      },
      { 
        title: "SaladGreen", 
        description: "Eat Clean, Live Green. 농장에서 식탁까지, 가장 신선한 재료로 채우는 건강한 한 끼.", 
        category: "dining", 
        preview_url: "/templates/salad", 
        image_url: "/images/templates/salad_green.png",
        is_featured: false
      },
      { 
        title: "ARCHIVE", 
        description: "크리에이터를 위한 다크모드 그리드 갤러리. 작품에만 집중할 수 있는 디자인.", 
        category: "portfolio", 
        preview_url: "/templates/portfolio", 
        image_url: "/images/templates/portfolio_gallery.png",
        is_featured: false
      },
      { 
        title: "Pure Clinic", 
        description: "깨끗하고 전문적인 느낌의 클리닉 스타일. 신뢰감을 주는 의료진 소개 섹션.", 
        category: "medical", 
        preview_url: "/templates/medical", 
        image_url: "/images/templates/skin_clinic_hero.png",
        is_featured: false
      },
      { 
        title: "법무법인 정의", 
        description: "당신의 권리를 지키는 든든한 법률 파트너. 무료 법률 상담 제공.", 
        category: "law", 
        preview_url: "/templates/law", 
        image_url: "/images/templates/justice_law.png",
        is_featured: false
      },
      { 
        title: "Grand Hotel", 
        description: "A Sanctuary of Elegance. 도심 속 완벽한 휴식처, 그랜드 호텔.", 
        category: "stay", 
        preview_url: "/templates/hotel", 
        image_url: "/images/templates/hotel_grand.png",
        is_featured: false
      },
      { 
        title: "클린 싹싹", 
        description: "건물위생관리업 정식 등록업체. 신뢰감을 주는 블루톤의 전문 청소업체 템플릿.", 
        category: "space", 
        preview_url: "/templates/cleaning", 
        image_url: "/images/templates/cleaning_main.png",
        is_featured: true
      },
      { 
        title: "Flower & Garden", 
        description: "Bloom Where You Are. 계절의 가장 아름다운 순간을 꽃으로 전합니다.", 
        category: "shopping", 
        preview_url: "/templates/flower", 
        image_url: "/images/templates/flower_garden.png",
        is_featured: false
      },
      { 
        title: "Rent-All", 
        description: "쉽고 빠른 렌터카 예약. 직관적인 검색 바와 차량 상세 정보 카드.", 
        category: "corporate", 
        preview_url: "/templates/rental", 
        image_url: "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?q=80&w=800",
        is_featured: false
      },
      { 
        title: "Invest Future", 
        description: "성공적인 자산 관리 파트너. 신뢰를 주는 차분한 블루 그레이 톤.", 
        category: "finance", 
        preview_url: "/templates/finance", 
        image_url: "/images/templates/finance_invest.png",
        is_featured: false
      },
      { 
        title: "Code Academy", 
        description: "당신의 아이디어를 <Code>로 실현하세요. 체계적인 커리큘럼과 현업 멘토링.", 
        category: "academy", 
        preview_url: "/templates/academy", 
        image_url: "/images/templates/code_academy.png",
        is_featured: false
      },
      { 
        title: "Little Star", 
        description: "Play, Learn & Grow! 신나는 놀이 속에서 자연스럽게 영어를 배워요.", 
        category: "kinder", 
        preview_url: "/templates/kinder", 
        image_url: "/images/templates/little_star.png",
        is_featured: false
      },
      { 
        title: "Dental Care", 
        description: "편안하고 믿을 수 있는 치과. 예약 시스템과 시술 전후 비교 갤러리.", 
        category: "medical", 
        preview_url: "/templates/dental", 
        image_url: "https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?q=80&w=800",
        is_featured: false
      },
      { 
        title: "Happy Vet", 
        description: "24시간 동물의료센터. 반려동물 집사를 위한 친근한 디자인과 정보 제공.", 
        category: "medical", 
        preview_url: "/templates/vet", 
        image_url: "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=800",
        is_featured: false
      },
      { 
        title: "Tax Partner", 
        description: "Save More, Worry Less. 복잡한 세금, 전문가에게 맡기세요.", 
        category: "law", 
        preview_url: "/templates/tax", 
        image_url: "/images/templates/tax_partner.png",
        is_featured: false
      },
      { 
        title: "Wild Camp", 
        description: "자연 속 힐링을 위한 감성 캠핑장. 아웃도어 기어 렌탈 및 사이트 예약.", 
        category: "stay", 
        preview_url: "/templates/camping", 
        image_url: "/images/templates/camping_tent.png",
        is_featured: false
      },
      { 
        title: "Minimal Studio", 
        description: "Less is More. 옷의 질감과 실루엣을 강조하는 심플한 UI.", 
        category: "shopping", 
        preview_url: "/templates/cloth", 
        image_url: "/images/templates/minimal_studio.png",
        is_featured: false
      },
      { 
        title: "Urban Kicks", 
        description: "Run The Streets. 스트릿 스타일 스니커즈 편집샵. 한정판 드롭 타이머와 응모 시스템.", 
        category: "shopping", 
        preview_url: "/templates/shoe", 
        image_url: "/images/templates/urban_kicks.png",
        is_featured: false
      },
      { 
        title: "L'Atelier", 
        description: "The Art of Leather. 최상급 이탈리아 가죽과 장인의 손길로 완성된 불변의 가치.", 
        category: "shopping", 
        preview_url: "/templates/bag", 
        image_url: "/images/templates/leather_atelier.png",
        is_featured: false
      }
    ]

    templates.each do |t|
      template = DesignTemplate.find_or_initialize_by(preview_url: t[:preview_url])
      puts "Updating Template: #{t[:title]}"
      template.update!(
        title: t[:title],
        description: t[:description],
        category: t[:category],
        image_url: t[:image_url],
        is_featured: t[:is_featured]
      )
    end

    puts "Updated #{DesignTemplate.count} templates with new PC images"
  end

  def down
    # Migration is not reversible
  end
end
