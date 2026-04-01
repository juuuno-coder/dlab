class ApplyCorrectKoreanData < ActiveRecord::Migration[8.1]
  class DesignTemplate < ActiveRecord::Base; end

  def up
    # 템플릿 데이터 정의 (한글 & 로컬 이미지 우선)
    # seeds.rb와 동일한 데이터를 강제로 적용하여 DB 상태를 교정함
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
        image_url: "https://images.unsplash.com/photo-1559339352-11d035aa65de?q=80&w=800&auto=format&fit=crop",
        is_featured: true 
      },
      { 
        title: "Sculpt & Soul", 
        description: "아티스틱 웰니스 브랜드 스타일. 감각적인 다크 모드와 타이포그래피.", 
        category: "fitness", 
        preview_url: "/templates/gym", 
        image_url: "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=800"
      },
      { 
        title: "Focus Lab", 
        description: "건축적인 조형미가 돋보이는 스터디 랩 스타일. 집중력을 높이는 미니멀리즘.", 
        category: "space", 
        preview_url: "/templates/study", 
        image_url: "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=800"
      },
      { 
        title: "Cozy Stay", 
        description: "한옥의 정취를 담은 감성 스테이. 수평 스크롤 스토리텔링.", 
        category: "stay", 
        preview_url: "/templates/pension", 
        image_url: "/images/templates/pension_spa.png",
        is_featured: true 
      },
      { 
        title: "The Avenue", 
        description: "큐레이션이 돋보이는 모던 패션 멀티샵. 트렌디한 룩북 스타일.", 
        category: "shopping", 
        preview_url: "/templates/shopping", 
        image_url: "/images/templates/shopping_new_arrivals.png",
        is_featured: true
      },
      { 
        title: "Novus", 
        description: "신뢰감을 주는 블루톤의 IT 스타트업 스타일. 데이터 시각화 섹션 포함.", 
        category: "corporate", 
        preview_url: "/templates/startup", 
        image_url: "https://images.unsplash.com/photo-1551434678-e076c2236034?q=80&w=800"
      },
      { 
        title: "Daily Crumb", 
        description: "따뜻한 베이지톤의 감성 베이커리 스타일. 인스타그램 피드 연동 디자인.", 
        category: "cafe", 
        preview_url: "/templates/cafe", 
        image_url: "/images/templates/cafe_baguette.png"
      },
      { 
        title: "ARCHIVE", 
        description: "크리에이터를 위한 다크모드 그리드 갤러리. 작품에만 집중할 수 있는 디자인.", 
        category: "portfolio", 
        preview_url: "/templates/portfolio", 
        image_url: "https://images.unsplash.com/photo-1600607686527-6fb886090705?q=80&w=800"
      },
      { 
        title: "Pure Clinic", 
        description: "깨끗하고 전문적인 느낌의 클리닉 스타일. 신뢰감을 주는 의료진 소개 섹션.", 
        category: "medical", 
        preview_url: "/templates/medical", 
        image_url: "/images/templates/skin_clinic_hero.png"
      },
      { 
        title: "Justice Law", 
        description: "세리프 폰트와 네이비 컬러로 무게감을 준 전문직. 성공 사례 중심 레이아웃.", 
        category: "law", 
        preview_url: "/templates/law", 
        image_url: "https://images.unsplash.com/photo-1589829085413-56de8ae18c73?q=80&w=800"
      },
      { 
        title: "Grand Hotel", 
        description: "우아하고 럭셔리한 5성급 호텔 스타일. 객실/다이닝 예약 최적화.", 
        category: "stay", 
        preview_url: "/templates/hotel", 
        image_url: "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?q=80&w=800"
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
        description: "우아한 플로리스트 포트폴리오. 식물의 싱그러움을 담은 내추럴&보태니컬 디자인.", 
        category: "shopping", 
        preview_url: "/templates/flower", 
        image_url: "/images/templates/flower_shop_hero_1.png"
      },
      { 
        title: "Rent-All", 
        description: "쉽고 빠른 렌터카 예약. 직관적인 검색 바와 차량 상세 정보 카드.", 
        category: "corporate", 
        preview_url: "/templates/rental", 
        image_url: "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?q=80&w=800"
      },
      { 
        title: "Invest Future", 
        description: "성공적인 자산 관리 파트너. 신뢰를 주는 차분한 블루 그레이 톤.", 
        category: "finance", 
        preview_url: "/templates/finance", 
        image_url: "https://images.unsplash.com/photo-1579532537598-459ecdaf39cc?q=80&w=800"
      },
      { 
        title: "Code Academy", 
        description: "미래를 여는 코딩 교육. 테크니컬한 그리드와 로드맵 시각화.", 
        category: "academy", 
        preview_url: "/templates/academy", 
        image_url: "https://images.unsplash.com/photo-1571171637578-41bc2dd41cd2?q=80&w=800"
      },
      { 
        title: "Little Star", 
        description: "아이들의 창의력을 자극하는 영어 유치원. 알록달록한 컬러와 귀여운 일러스트.", 
        category: "kinder", 
        preview_url: "/templates/kinder", 
        image_url: "https://images.unsplash.com/photo-1588072432836-e10032774350?q=80&w=800"
      },
      { 
        title: "Dental Care", 
        description: "편안하고 믿을 수 있는 치과. 예약 시스템과 시술 전후 비교 갤러리.", 
        category: "medical", 
        preview_url: "/templates/dental", 
        image_url: "https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?q=80&w=800"
      },
      { 
        title: "Happy Vet", 
        description: "24시간 동물의료센터. 반려동물 집사를 위한 친근한 디자인과 정보 제공.", 
        category: "medical", 
        preview_url: "/templates/vet", 
        image_url: "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=800"
      },
      { 
        title: "Tax Partner", 
        description: "스마트한 세무 파트너. 복잡한 세금을 쉽게 계산해주는 계산기 위젯 포함.", 
        category: "law", 
        preview_url: "/templates/tax", 
        image_url: "https://images.unsplash.com/photo-1554224155-984063584d45?q=80&w=800"
      },
      { 
        title: "Wild Camp", 
        description: "자연 속 힐링을 위한 감성 캠핑장. 아웃도어 기어 렌탈 및 사이트 예약.", 
        category: "stay", 
        preview_url: "/templates/camping", 
        image_url: "https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?q=80&w=800"
      },
      { 
        title: "Minimal Studio", 
        description: "미니멀리즘 패션 브랜드. 옷의 질감과 실루엣을 강조하는 심플한 UI.", 
        category: "shopping", 
        preview_url: "/templates/cloth", 
        image_url: "https://images.unsplash.com/photo-1441986300917-64674bd600d8?q=80&w=800"
      },
      { 
        title: "Urban Kicks", 
        description: "스트릿 스타일 스니커즈 편집샵. 한정판 드롭 타이머와 응모 시스템.", 
        category: "shopping", 
        preview_url: "/templates/shoe", 
        image_url: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=800"
      },
      { 
        title: "L'Atelier", 
        description: "장인정신이 깃든 가죽 공방. 클래식한 감성과 제작 과정 스토리텔링.", 
        category: "shopping", 
        preview_url: "/templates/bag", 
        image_url: "https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=800"
      }
    ]

    # 기존 데이터 모두 업데이트
    templates.each do |t|
      template = DesignTemplate.find_or_initialize_by(preview_url: t[:preview_url])
      puts "Migrating Template: #{t[:title]}"
      template.update!(
        title: t[:title],
        description: t[:description],
        category: t[:category],
        image_url: t[:image_url],
        is_featured: t[:is_featured] || false
      )
    end
  end
end
