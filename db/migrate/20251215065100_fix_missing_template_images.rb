class FixMissingTemplateImages < ActiveRecord::Migration[8.1]
  class DesignTemplate < ActiveRecord::Base; end

  def up
    # 로컬 이미지 경로로 업데이트 (이 이미지들은 public/images/templates/ 에 있음)
    image_mappings = {
      # 쇼핑/패션 카테고리
      "The Avenue" => "/images/templates/the_avenue.png",
      "L'Atelier" => "/images/templates/leather_atelier.png",
      "Urban Kicks" => "/images/templates/urban_kicks.png",
      
      # 공간/스튜디오
      "Minimal Studio" => "/images/templates/minimal_studio.png",
      
      # 꽃/플라워
      "Flower & Garden" => "/images/templates/flower_garden.png",
      
      # 교육/학원
      "Code Academy" => "/images/templates/code_academy.png",
      "Little Star" => "/images/templates/little_star.png",
      
      # 숙박/여행
      "Grand Hotel" => "/images/templates/hotel_grand.png",
      "Cozy Stay" => "/images/templates/cozy_stay.png",
      
      # 기업/SaaS
      "Novus" => "/images/templates/novus_saas.png",
      
      # 피트니스
      "Yoga Flow" => "/images/templates/yoga_flow.png",
      
      # 법률
      "법무법인 정의" => "/images/templates/justice_law.png",
      
      # 세무
      "Tax Partner" => "/images/templates/tax_partner.png",
      
      # 다이닝/F&B
      "SweetSpot" => "/images/templates/sweetspot_donut.png",
      "SaladGreen" => "/images/templates/salad_green.png"
    }

    image_mappings.each do |title, image_path|
      template = DesignTemplate.find_by(title: title)
      if template
        puts "Updating #{title} image to: #{image_path}"
        template.update_column(:image_url, image_path)
      else
        puts "Template not found: #{title}"
      end
    end

    puts "Updated #{image_mappings.count} templates with local image paths"
  end

  def down
    # Revert to Unsplash images would require storing the old URLs
    # This is a one-way migration
  end
end
