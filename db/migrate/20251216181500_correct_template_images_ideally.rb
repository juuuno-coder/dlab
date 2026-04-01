class CorrectTemplateImagesIdeally < ActiveRecord::Migration[7.1]
  def up
    # 1. Sweet Spot (Cafe) - 서버 내 로컬 이미지 사용 (가장 안전)
    # 파일명: sweetspot_donut.png
    sweet_spot = DesignTemplate.find_by(title: "Sweet Spot")
    if sweet_spot
      sweet_spot.pc_image.purge if sweet_spot.pc_image.attached?
      sweet_spot.mobile_image.purge if sweet_spot.mobile_image.attached?
      sweet_spot.update_columns(image_url: "/images/templates/sweetspot_donut.png")
    end

    # 2. Burger House (Dining) - 진짜 햄버거 사진으로 교체
    # Unsplash ID: photo-1568901346375-23c9450c58cd (Cheeseburger closeup)
    burger_house = DesignTemplate.find_by(title: "Burger House")
    if burger_house
      burger_house.pc_image.purge if burger_house.pc_image.attached?
      burger_house.mobile_image.purge if burger_house.mobile_image.attached?
      burger_house.update_columns(image_url: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=800&auto=format&fit=crop")
    end
  end
end
