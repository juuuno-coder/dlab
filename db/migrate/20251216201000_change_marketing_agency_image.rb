class ChangeMarketingAgencyImage < ActiveRecord::Migration[7.1]
  def up
    # Marketing Agency 이미지가 Rent-All(자동차)과 중복되는 문제 해결
    # 크리에이티브한 에이전시 팀 미팅 이미지로 교체
    # Image: https://images.unsplash.com/photo-1522071820081-009f0129c71c
    target = DesignTemplate.find_by(title: "Marketing Agency")
    if target
      target.pc_image.purge if target.pc_image.attached?
      target.mobile_image.purge if target.mobile_image.attached?
      target.update_columns(image_url: "https://images.unsplash.com/photo-1522071820081-009f0129c71c?q=80&w=800&auto=format&fit=crop")
    end
  end

  def down
  end
end
