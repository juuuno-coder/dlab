# Quick seed script - run with: ruby db/quick_seed.rb
require_relative '../config/environment'

puts "🌱 Starting quick seed..."

# Clear existing templates
puts "Clearing existing templates..."
DesignTemplate.destroy_all

# Template data
templates = [
  { title: "LUMIER", description: "청담동 하이엔드 살롱 스타일. 고급스러운 세리프 폰트와 인물 중심 레이아웃.", category: "beauty", preview_url: "/templates/beauty", image_url: "https://images.unsplash.com/photo-1560066984-138dadb4c035?q=80&w=800&auto=format&fit=crop", is_featured: true },
  { title: "溫 (ON)", description: "여백의 미를 살린 모던 오마카세 다이닝 스타일. 갤러리 같은 메뉴 소개 디자인.", category: "dining", preview_url: "/templates/dining", image_url: "https://images.unsplash.com/photo-1559339352-11d035aa65de?q=80&w=800&auto=format&fit=crop", is_featured: true },
  { title: "Sculpt & Soul", description: "아티스틱 웰니스 브랜드 스타일. 감각적인 다크 모드와 타이포그래피.", category: "fitness", preview_url: "/templates/gym", image_url: "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=800" },
  { title: "Focus Lab", description: "건축적인 조형미가 돋보이는 스터디 랩 스타일. 집중력을 높이는 미니멀리즘.", category: "space", preview_url: "/templates/study", image_url: "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=800" },
  { title: "서촌 쉼", description: "한옥의 정취를 담은 감성 스테이. 수평 스크롤 스토리텔링.", category: "stay", preview_url: "/templates/stay", image_url: "https://images.unsplash.com/photo-1610641818989-c2051b5e2cfd?q=80&w=800", is_featured: true },
  { title: "AETHER", description: "이미지가 돋보이는 모던 시크 패션 브랜드. 상품 디테일을 살리는 레이아웃.", category: "shopping", preview_url: "/templates/ecommerce", image_url: "https://images.unsplash.com/photo-1445205170230-053b83016050?q=80&w=800" },
  { title: "Novus", description: "신뢰감을 주는 블루톤의 IT 스타트업 스타일. 데이터 시각화 섹션 포함.", category: "corporate", preview_url: "/templates/corporate", image_url: "https://images.unsplash.com/photo-1551434678-e076c2236034?q=80&w=800" },
  { title: "Daily Crumb", description: "따뜻한 베이지톤의 감성 베이커리 스타일. 인스타그램 피드 연동 디자인.", category: "cafe", preview_url: "/templates/cafe", image_url: "https://images.unsplash.com/photo-1549931319-a545dcf3bc73?q=80&w=800" },
  { title: "ARCHIVE", description: "크리에이터를 위한 다크모드 그리드 갤러리. 작품에만 집중할 수 있는 디자인.", category: "portfolio", preview_url: "/templates/portfolio", image_url: "https://images.unsplash.com/photo-1600607686527-6fb886090705?q=80&w=800" },
  { title: "Pure Clinic", description: "깨끗하고 전문적인 느낌의 클리닉 스타일. 신뢰감을 주는 의료진 소개 섹션.", category: "medical", preview_url: "/templates/medical", image_url: "https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?q=80&w=800" },
  { title: "Trust & Logic", description: "세리프 폰트와 네이비 컬러로 무게감을 준 전문직. 성공 사례 중심 레이아웃.", category: "law", preview_url: "/templates/law", image_url: "https://images.unsplash.com/photo-1589829085413-56de8ae18c73?q=80&w=800" },
  { title: "Bliss", description: "우아하고 로맨틱한 웨딩 플래너/베뉴 템플릿. 감성적인 비주얼 스토리텔링.", category: "stay", preview_url: "/templates/wedding", image_url: "https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=800" },
  { title: "클린 싹싹", description: "건물위생관리업 정식 등록업체. 신뢰감을 주는 블루톤의 전문 청소업체 템플릿.", category: "space", preview_url: "/templates/cleaning", image_url: "https://images.unsplash.com/photo-1581578731548-c64695cc6952?q=80&w=800", is_featured: true },
  { title: "Urban Fit", description: "에너지 넘치는 현대적인 크로스핏/헬스장 템플릿. 강렬한 타이포그래피와 다이내믹한 레이아웃.", category: "fitness", preview_url: "/templates/gym", image_url: "https://images.unsplash.com/photo-1540497077202-7c8a3999166f?q=80&w=800" },
  { title: "Pet Palace", description: "반려동물을 위한 프리미엄 케어 서비스. 부드러운 곡선과 따뜻한 파스텔톤 컬러.", category: "shopping", preview_url: "/templates/ecommerce", image_url: "https://images.unsplash.com/photo-1548199973-03cce0bbc87b?q=80&w=800" },
  { title: "Kids Station", description: "아이들의 창의력을 자극하는 키즈카페. 알록달록한 컬러와 귀여운 일러스트 아이콘.", category: "space", preview_url: "/templates/cafe", image_url: "https://images.unsplash.com/photo-1566737236500-c8ac43014a67?q=80&w=800" },
  { title: "Camp Vibez", description: "자연 속 힐링을 위한 감성 캠핑장. 예약 시스템 UI가 최적화된 아웃도어 스타일.", category: "stay", preview_url: "/templates/stay", image_url: "https://images.unsplash.com/photo-1478131143081-80f7f84ca84d?q=80&w=800" },
  { title: "Flower & Garden", description: "우아한 플로리스트 포트폴리오. 식물의 싱그러움을 담은 내추럴&보태니컬 디자인.", category: "shopping", preview_url: "/templates/beauty", image_url: "https://images.unsplash.com/photo-1562690868-60bbe703395b?q=80&w=800" },
  { title: "Burger House", description: "힙한 수제버거 브랜드. 식욕을 자극하는 비비드한 컬러와 굵은 고딕 폰트.", category: "dining", preview_url: "/templates/dining", image_url: "https://images.unsplash.com/photo-1586190848861-99c9574548e3?q=80&w=800" },
  { title: "Wine Social", description: "어두운 조명의 분위기 있는 와인바. 고급스러운 블랙 배경과 골드 포인트.", category: "dining", preview_url: "/templates/dining", image_url: "https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?q=80&w=800" },
  { title: "Yoga Flow", description: "마음의 평화를 찾는 요가 스튜디오. 차분한 그린과 화이트 톤의 힐링 디자인.", category: "fitness", preview_url: "/templates/gym", image_url: "https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=800" },
  { title: "Nail Artistry", description: "트렌디한 네일아트 살롱. 작품 갤러리와 예약 시스템이 돋보이는 핑크톤 디자인.", category: "beauty", preview_url: "/templates/beauty", image_url: "https://images.unsplash.com/photo-1604654894610-df63bc536371?q=80&w=800" },
  { title: "Barber Classic", description: "클래식한 남성 이발소. 빈티지 감성의 브라운 톤과 레트로 타이포그래피.", category: "beauty", preview_url: "/templates/beauty", image_url: "https://images.unsplash.com/photo-1503951914875-452162b0f3f1?q=80&w=800" },
  { title: "Skin Lab", description: "피부과학 기반 스킨케어 클리닉. 깔끔한 화이트 베이스와 과학적인 데이터 시각화.", category: "beauty", preview_url: "/templates/medical", image_url: "https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=800" },
  { title: "Dental Care", description: "밝고 친근한 치과 병원. 환자 중심의 따뜻한 블루 컬러와 안심 케어 메시지.", category: "medical", preview_url: "/templates/medical", image_url: "https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?q=80&w=800" },
  { title: "Pet Hospital", description: "반려동물 전문 동물병원. 귀여운 일러스트와 안심할 수 있는 파스텔 컬러.", category: "medical", preview_url: "/templates/medical", image_url: "https://images.unsplash.com/photo-1530281700549-e82e7bf110d6?q=80&w=800" },
  { title: "Law Firm Pro", description: "대형 로펌 스타일. 신뢰와 권위를 상징하는 다크 네이비와 골드 포인트.", category: "law", preview_url: "/templates/law", image_url: "https://images.unsplash.com/photo-1589829085413-56de8ae18c73?q=80&w=800" },
  { title: "Accounting Plus", description: "회계법인 전문 템플릿. 숫자와 데이터를 효과적으로 보여주는 차트 중심 레이아웃.", category: "law", preview_url: "/templates/corporate", image_url: "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?q=80&w=800" },
  { title: "Consulting Hub", description: "경영 컨설팅 회사. 전문성을 강조하는 그레이 톤과 케이스 스터디 섹션.", category: "corporate", preview_url: "/templates/corporate", image_url: "https://images.unsplash.com/photo-1542744173-8e7e53415bb0?q=80&w=800" },
  { title: "Marketing Agency", description: "크리에이티브 마케팅 에이전시. 화려한 그라데이션과 포트폴리오 갤러리.", category: "corporate", preview_url: "/templates/corporate", image_url: "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?q=80&w=800" },
  { title: "Photo Studio", description: "순간을 기록하는 사진관. 갤러리 형태의 레이아웃으로 사진에 집중.", category: "portfolio", preview_url: "/templates/portfolio", image_url: "https://images.unsplash.com/photo-1554048612-387768052bf7?q=80&w=800" },
  { title: "Tattoo Ink", description: "개성을 새기는 타투샵. 강렬하고 힙한 분위기의 블랙&화이트 포트폴리오.", category: "portfolio", preview_url: "/templates/portfolio", image_url: "https://images.unsplash.com/photo-1598371839696-5c5bb62d4067?q=80&w=800" },
  { title: "Tax Pro", description: "신뢰받는 세무 파트너. 전문적인 느낌의 네이비 컬러와 깔끔한 아이콘.", category: "law", preview_url: "/templates/law", image_url: "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?q=80&w=800" }
]

# Create templates
puts "Creating #{templates.count} templates..."
templates.each_with_index do |t, index|
  template = DesignTemplate.create!(t)
  print "."
  print " #{index + 1}" if (index + 1) % 10 == 0
end

puts "\n✅ Done! Created #{DesignTemplate.count} templates"
puts "Featured templates: #{DesignTemplate.where(is_featured: true).count}"
