# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding Design Templates..."

# 템플릿 데이터 정의 (사용자 요청에 맞춘 한글 명칭 및 매칭)
templates = [
  { 
    title: "LUMIER 세미나", 
    description: "청담동 하이엔드 살롱 컨셉의 뷰티 브랜드 템플릿. 우아한 세리프와 그리드 레이아웃.", 
    category: "beauty", 
    preview_url: "/templates/beauty", 
    image_url: "https://images.unsplash.com/photo-1560750588-73207b1ef5b8?q=80&w=800",
    is_featured: true 
  },
  { 
    title: "溫 (ON) 다이닝", 
    description: "여백의 미를 살린 프리미엄 오마카세 다이닝. 고요하고 감각적인 디자인.", 
    category: "dining", 
    preview_url: "/templates/dining", 
    image_url: "https://images.unsplash.com/photo-1559339352-11d035aa65de?q=80&w=800",
    is_featured: true 
  },
  { 
    title: "에테르노 필라테스", 
    description: "프리미엄 필라테스 스튜디오를 위한 슬릭하고 모던한 디자인. 내면의 균형을 강조.", 
    category: "fitness", 
    preview_url: "/templates/sculpt", 
    image_url: "https://images.unsplash.com/photo-1518310383802-640c2de311b2?q=80&w=800"
  },
  { 
    title: "요가 플로우", 
    description: "심플하고 차분한 무드. 요가 및 명상 센터를 위한 자연 친화적 템플릿.", 
    category: "fitness", 
    preview_url: "/templates/yoga", 
    image_url: "https://images.unsplash.com/photo-1545208393-2160291ba69e?q=80&w=800",
    is_featured: true
  },
  { 
    title: "라이브러리 원", 
    description: "프리미엄 스터디 라운지를 위한 세련된 다크 모드 디자인. 완벽한 몰입을 선사합니다.", 
    category: "space", 
    preview_url: "/templates/study", 
    image_url: "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=800",
    is_featured: true
  },
  { 
    title: "리버사이드 스테이", 
    description: "감성 숙소와 독채 펜션을 위한 포트폴리오 스타일. 제주 등 여행지 컨셉.", 
    category: "stay", 
    preview_url: "/templates/stay", 
    image_url: "https://images.unsplash.com/photo-1584132967334-10e028bd69f7?q=80&w=800",
    is_featured: true 
  },
  { 
    title: "The Avenue", 
    description: "큐레이션이 돋보이는 패션 멀티샵. 브랜드 룩북 중심의 트렌디한 구성.", 
    category: "shopping", 
    preview_url: "/templates/shopping", 
    image_url: "https://images.unsplash.com/photo-1441986300917-64674bd600d8?q=80&w=800",
    is_featured: true
  },
  { 
    title: "Novus 비즈니스", 
    description: "IT 스타트업 및 SaaS를 위한 올인원 협업 툴 컨셉의 메쉬 그라디언트 디자인.", 
    category: "corporate", 
    preview_url: "/templates/startup", 
    image_url: "https://images.unsplash.com/photo-1460925895917-afdab827c52f?q=80&w=800"
  },
  { 
    title: "데일리 크럼", 
    description: "감성적인 무드의 베이커리. 정성 담긴 빵과 따뜻한 소통을 위한 카페 템플릿.", 
    category: "cafe", 
    preview_url: "/templates/cafe", 
    image_url: "https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=800",
    is_featured: true
  },
  { 
    title: "롤링도넛", 
    description: "팝한 컬러감과 폰트가 돋보이는 디저트 샵 전용 템플릿. 'Life is Sweet'.", 
    category: "cafe", 
    preview_url: "/templates/donut", 
    image_url: "https://images.unsplash.com/photo-1506152983158-b4a74a01c721?q=80&w=800",
    is_featured: true
  },
  { 
    title: "그린스 앤 그레인", 
    description: "가장 신선한 샐러드와 건강을 한 그릇에 담은 다목적 다이닝 템플릿.", 
    category: "dining", 
    preview_url: "/templates/salad", 
    image_url: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=800"
  },
  { 
    title: "에이전시X", 
    description: "디지털 혁신을 주도하는 크리에이티브 스튜디오 포트폴리오. 파격적인 무드.", 
    category: "portfolio", 
    preview_url: "/templates/agency", 
    image_url: "https://images.unsplash.com/photo-1550745165-9bc0b252726f?q=80&w=800",
    is_featured: true
  },
  { 
    title: "미소라인 의원", 
    description: "신뢰감을 주는 화이트 톤의 메디컬 클리닉. 전문 의료진과 시술 정보를 한눈에.", 
    category: "medical", 
    preview_url: "/templates/medical", 
    image_url: "https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?q=80&w=800",
    is_featured: true
  },
  { 
    title: "법무법인 정의", 
    description: "무게감 있는 전통적인 법률 전문가 그룹 템플릿. 신뢰와 권위를 강조.", 
    category: "law", 
    preview_url: "/templates/law", 
    image_url: "https://images.unsplash.com/photo-1589829545856-d10d557cf95f?q=80&w=800",
    is_featured: true
  },
  { 
    title: "그랜드 오션", 
    description: "바다가 보이는 프리미엄 호텔 템플릿. 시원한 레이아웃과 감성적인 무드.", 
    category: "stay", 
    preview_url: "/templates/hotel", 
    image_url: "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?q=80&w=800",
    is_featured: true
  },
  { 
    title: "클린싹싹", 
    description: "신뢰감을 주는 전문 청소 서비스 템플릿. 깔끔한 블루톤과 직관적인 서비스 소개.", 
    category: "space", 
    preview_url: "/templates/cleaning", 
    image_url: "https://images.unsplash.com/photo-1581578731548-c64695cc6958?q=80&w=800",
    is_featured: true
  },
  { 
    title: "와이즈 에셋", 
    description: "성공적인 자산을 위한 금융 파트너. 정제된 레이아웃과 안정감을 주는 디자인.", 
    category: "finance", 
    preview_url: "/templates/finance", 
    image_url: "https://images.unsplash.com/photo-1460925895917-afdab827c52f?q=80&w=800",
    is_featured: true
  },
  { 
    title: "K-Accounting", 
    description: "공인회계사회 스타일의 신뢰감 있는 회계/세무 법인 전용 템플릿. 정보 중심의 UI.", 
    category: "finance", 
    preview_url: "/templates/accounting", 
    image_url: "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?q=80&w=800",
    is_featured: true
  },
  { 
    title: "대치 엘리트", 
    description: "최고의 입시 및 코딩 교육 아카데미를 위한 클래식 세리프 디자인.", 
    category: "academy", 
    preview_url: "/templates/academy", 
    image_url: "https://images.unsplash.com/photo-1501504905252-473c47e087f8?q=80&w=800",
    is_featured: true
  },
  { 
    title: "MUA 진 치과", 
    description: "전문 의료진 정보와 차별화된 예약 시스템을 갖춘 현대적 치과 템플릿.", 
    category: "medical", 
    preview_url: "/templates/dental", 
    image_url: "https://images.unsplash.com/photo-1629909613654-28e377c37b09?q=80&w=800",
    is_featured: true
  },
  { 
    title: "위드 펫", 
    description: "반려동물을 위한 24시간 토탈 케어 솔루션. 따뜻하고 친근한 디자인.", 
    category: "medical", 
    preview_url: "/templates/vet", 
    image_url: "https://images.unsplash.com/photo-1583337130417-3346a1be7dee?q=80&w=800",
    is_featured: true
  },
  { 
    title: "어반 킥스", 
    description: "스트릿 스니커즈 편집샵. 강렬한 대비와 역동적인 레이아웃의 쇼핑몰.", 
    category: "shopping", 
    preview_url: "/templates/shoe", 
    image_url: "https://images.unsplash.com/photo-1552346154-21d32810aba3?q=80&w=800",
    is_featured: true
  },
  { 
    title: "SKILLUP", 
    description: "내일의 성장을 위한 온라인 강의 플랫폼. 직관적인 카테고리 구성.", 
    category: "academy", 
    preview_url: "/templates/learnhub", 
    image_url: "https://images.unsplash.com/photo-1501504905252-473c47e087f8?q=80&w=800",
    is_featured: true
  },
  { 
    title: "빈티지 1988", 
    description: "열정과 시간이 빚어낸 고귀한 와인 컬렉션을 위한 럭셔리 템플릿.", 
    category: "dining", 
    preview_url: "/templates/wine", 
    image_url: "https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?q=80&w=800",
    is_featured: true
  }
]

# 기존 데이터 업데이트 및 카테고리 매칭 교정
templates.each do |t|
  template = DesignTemplate.find_or_initialize_by(preview_url: t[:preview_url])
  puts "Updating Template: #{t[:title]}"
  template.update!(
    title: t[:title],
    description: t[:description],
    category: t[:category],
    image_url: t[:image_url],
    is_featured: t[:is_featured] || false
  )
end

puts "Seed Data Updated Successfully: #{DesignTemplate.count} Templates"

# ===== Agency Seed Data (Multi-tenant Branding) =====
puts "\nSeeding Agencies..."

# super_admin 유저 확보 (없으면 생성)
admin_user = User.find_by(role: "super_admin") || User.first
unless admin_user
  admin_user = User.create!(
    email: "admin@designd.co.kr",
    password: "changeme123!",
    name: "Admin",
    role: "super_admin"
  )
  puts "Created admin user: #{admin_user.email}"
end

# dlab 브랜딩 설정
dlab_settings = {
  "brand_name" => "디랩",
  "company_name" => "주식회사디랩 (D.Lab Corp)",
  "tagline" => "AI와 기술의 힘으로 비즈니스를 혁신합니다",
  "sub_tagline" => "바이버스 플랫폼과 맞춤 솔루션으로 디지털 전환을 가속화합니다",
  "hero_stats" => [
    { "number" => "AI", "label" => "네이티브 개발" },
    { "number" => "5+", "label" => "사업체 운영" },
    { "number" => "맞춤형", "label" => "솔루션 제공" },
    { "number" => "풀스택", "label" => "기술 지원" }
  ],
  "why_title" => "왜 디랩일까요?",
  "why_subtitle" => "AI 네이티브 기술력과 실전 경험으로 비즈니스 성장을 함께합니다!",
  "primary_color" => "#1E3A8A",
  "primary_dark" => "#1e2f6a",
  "accent_color" => "#3B82F6",
  "contact_email" => "contact@dlab.co.kr",
  "meta_description" => "주식회사디랩 - AI 네이티브 개발사. 바이버스 플랫폼, 맞춤 웹/앱 개발, IT 컨설팅 서비스를 제공합니다.",
  "meta_keywords" => "디랩, D.Lab, AI개발, 웹개발, 앱개발, 바이버스, IT컨설팅, 디지털전환",
  "logo" => "logo.png",
  "copyright" => "주식회사디랩 (D.Lab Corp)"
}

Agency.find_or_create_by!(subdomain: "dlab") do |a|
  a.name = "주식회사디랩"
  a.owner = admin_user
  a.settings = dlab_settings
  a.active = true
  puts "Created agency: dlab.designd.co.kr"
end

Agency.find_or_create_by!(subdomain: "lab") do |a|
  a.name = "주식회사디랩 (lab)"
  a.owner = admin_user
  a.settings = dlab_settings
  a.active = true
  puts "Created agency: lab.designd.co.kr"
end

puts "Agency Seed Complete: #{Agency.count} agencies"
