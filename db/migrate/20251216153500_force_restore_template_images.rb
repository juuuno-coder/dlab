class ForceRestoreTemplateImages < ActiveRecord::Migration[7.1]
  def up
    # 템플릿 데이터 (quick_seed.rb에서 가져온 원본 URL)
    templates = [
      { title: "LUMIER", image_url: "https://images.unsplash.com/photo-1560066984-138dadb4c035?q=80&w=800&auto=format&fit=crop" },
      { title: "溫 (ON)", image_url: "https://images.unsplash.com/photo-1559339352-11d035aa65de?q=80&w=800&auto=format&fit=crop" },
      { title: "Sculpt & Soul", image_url: "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=800" },
      { title: "Focus Lab", image_url: "https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=800" },
      { title: "서촌 쉼", image_url: "https://images.unsplash.com/photo-1610641818989-c2051b5e2cfd?q=80&w=800" },
      { title: "AETHER", image_url: "https://images.unsplash.com/photo-1445205170230-053b83016050?q=80&w=800" },
      { title: "Novus", image_url: "https://images.unsplash.com/photo-1551434678-e076c2236034?q=80&w=800" },
      { title: "Daily Crumb", image_url: "https://images.unsplash.com/photo-1549931319-a545dcf3bc73?q=80&w=800" },
      { title: "ARCHIVE", image_url: "https://images.unsplash.com/photo-1600607686527-6fb886090705?q=80&w=800" },
      { title: "Pure Clinic", image_url: "https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?q=80&w=800" },
      { title: "Trust & Logic", image_url: "https://images.unsplash.com/photo-1589829085413-56de8ae18c73?q=80&w=800" },
      { title: "Bliss", image_url: "https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=800" },
      { title: "클린 싹싹", image_url: "https://images.unsplash.com/photo-1581578731548-c64695cc6952?q=80&w=800" },
      { title: "Urban Fit", image_url: "https://images.unsplash.com/photo-1540497077202-7c8a3999166f?q=80&w=800" },
      { title: "Pet Palace", image_url: "https://images.unsplash.com/photo-1548199973-03cce0bbc87b?q=80&w=800" },
      { title: "Kids Station", image_url: "https://images.unsplash.com/photo-1566737236500-c8ac43014a67?q=80&w=800" },
      { title: "Camp Vibez", image_url: "https://images.unsplash.com/photo-1478131143081-80f7f84ca84d?q=80&w=800" },
      { title: "Flower & Garden", image_url: "https://images.unsplash.com/photo-1562690868-60bbe703395b?q=80&w=800" },
      { title: "Burger House", image_url: "https://images.unsplash.com/photo-1586190848861-99c9574548e3?q=80&w=800" },
      { title: "Wine Social", image_url: "https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?q=80&w=800" },
      { title: "Yoga Flow", image_url: "https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=800" },
      { title: "Nail Artistry", image_url: "https://images.unsplash.com/photo-1604654894610-df63bc536371?q=80&w=800" },
      { title: "Barber Classic", image_url: "https://images.unsplash.com/photo-1503951914875-452162b0f3f1?q=80&w=800" },
      { title: "Skin Lab", image_url: "https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?q=80&w=800" },
      { title: "Dental Care", image_url: "https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?q=80&w=800" },
      { title: "Pet Hospital", image_url: "https://images.unsplash.com/photo-1530281700549-e82e7bf110d6?q=80&w=800" },
      { title: "Law Firm Pro", image_url: "https://images.unsplash.com/photo-1589829085413-56de8ae18c73?q=80&w=800" },
      { title: "Accounting Plus", image_url: "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?q=80&w=800" },
      { title: "Consulting Hub", image_url: "https://images.unsplash.com/photo-1542744173-8e7e53415bb0?q=80&w=800" },
      { title: "Marketing Agency", image_url: "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?q=80&w=800" },
      { title: "Photo Studio", image_url: "https://images.unsplash.com/photo-1554048612-387768052bf7?q=80&w=800" },
      { title: "Tattoo Ink", image_url: "https://images.unsplash.com/photo-1598371839696-5c5bb62d4067?q=80&w=800" },
      { title: "Tax Pro", image_url: "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?q=80&w=800" }
    ]

    templates.each do |t|
      # 제목으로 부분 일치 검색
      template = DesignTemplate.where("title LIKE ?", "%#{t[:title]}%").first
      if template
        # 1. ActiveStorage 연결 해제 (Purge) - 파일이 사라졌으므로 연결도 끊어야 함
        # Purge는 실제 파일 삭제도 시도하지만, 없으면 레코드만 지움.
        # rescue로 에러 방지
        begin
          template.pc_image.purge if template.pc_image.attached?
          template.mobile_image.purge if template.mobile_image.attached?
        rescue => e
          puts "Failed to purge images for #{template.title}: #{e.message}"
        end

        # 2. 원본 URL 복구
        template.update_columns(image_url: t[:image_url])
        puts "Restored image for: #{template.title}"
      end
    end
  end

  def down
    # 복구 작업이므로 롤백 불필요
  end
end
