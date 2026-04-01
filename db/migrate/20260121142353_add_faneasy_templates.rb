class AddFaneasyTemplates < ActiveRecord::Migration[8.1]
  def up
    # Existing Faneasy Site Data
    templates = [
      {
        title: "Bizon Marketing",
        description: "비즈온 마케팅 대행사 공식 홈페이지입니다.",
        category: "marketing",
        image_url: "https://imagedelivery.net/y4D_5-16J7qjQo4b7gGg9A/ce96378c-097c-473d-8380-606059d08e00/public",
        price: 3000000,
        preview_url: "https://bizon.faneasy.kr"
      },
      {
        title: "Oluolu Franchise",
        description: "올루올루 프랜차이즈 가맹점 모집 페이지입니다.",
        category: "franchise",
        image_url: "https://imagedelivery.net/y4D_5-16J7qjQo4b7gGg9A/36829745-f04b-4890-a382-723659966b00/public",
        price: 5000000,
        preview_url: "https://oluolu-franchise.faneasy.kr"
      },
      {
        title: "Oluolu Marketing",
        description: "올루올루 마케팅 랜딩 페이지 (Retro ver.)",
        category: "food_beverage", 
        image_url: "https://imagedelivery.net/y4D_5-16J7qjQo4b7gGg9A/62a78103-8d65-4f40-a359-548074d32000/public",
        price: 4000000,
        preview_url: "https://oluolu-marketing.faneasy.kr"
      },
      {
        title: "Kkang Agency",
        description: "깡대표 인플루언서 에이전시 템플릿입니다.",
        category: "influencer",
        image_url: "https://imagedelivery.net/y4D_5-16J7qjQo4b7gGg9A/0a8c2f82-1c25-4c0e-4389-948197772100/public",
        price: 2500000,
        preview_url: "https://kkang.faneasy.kr"
      },
       {
        title: "FanEasy Tech",
        description: "IT/Tech 스타트업을 위한 모던한 랜딩 페이지입니다.",
        category: "startup",
        image_url: "https://imagedelivery.net/y4D_5-16J7qjQo4b7gGg9A/87f6e098-2426-4d22-1d01-e73708e08d00/public",
        price: 3500000,
        preview_url: "https://tech.faneasy.kr"
      },
      {
        title: "MZ Growth Marketing",
        description: "MZ세대를 타겟으로 한 그로스 마케팅 페이지입니다.",
        category: "marketing",
        image_url: "https://imagedelivery.net/y4D_5-16J7qjQo4b7gGg9A/b8243615-5555-4148-9102-187518596600/public",
        price: 2800000, 
        preview_url: "https://mz.faneasy.kr"
      }
    ]

    templates.each do |data|
      # Check if already exists to avoid duplicates
      unless DesignTemplate.exists?(title: data[:title])
        DesignTemplate.create!(data)
      end
    end
  end

  def down
    DesignTemplate.where(title: [
      "Bizon Marketing", "Oluolu Franchise", "Oluolu Marketing", 
      "Kkang Agency", "FanEasy Tech", "MZ Growth Marketing"
    ]).destroy_all
  end
end
