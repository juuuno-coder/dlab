class FixSpecificBrokenImages < ActiveRecord::Migration[7.1]
  def up
    # 1. Sweet Spot (Cafe) - 대체 이미지 (도넛/디저트)
    # 기존 로컬 이미지가 로딩되지 않는 문제 해결을 위해 안정적인 Unsplash URL 사용
    template1 = DesignTemplate.find_by(title: "Sweet Spot")
    if template1
      template1.pc_image.purge if template1.pc_image.attached?
      template1.mobile_image.purge if template1.mobile_image.attached?
      template1.update_columns(image_url: "https://images.unsplash.com/photo-1551024601-564d6e67e8fd?q=80&w=800&auto=format&fit=crop")
    end

    # 2. Burger House (Dining) - 대체 이미지 (수제버거)
    # 로컬 이미지가 누락된 경우를 대비하여 Unsplash URL 사용
    template2 = DesignTemplate.find_by(title: "Burger House")
    if template2
      template2.pc_image.purge if template2.pc_image.attached?
      template2.mobile_image.purge if template2.mobile_image.attached?
      template2.update_columns(image_url: "https://images.unsplash.com/photo-1586190848861-99c9574548e3?q=80&w=800&auto=format&fit=crop")
    end
  end
end
