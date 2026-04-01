class MapAllLocalTemplatesToImages < ActiveRecord::Migration[8.1]
  class DesignTemplate < ActiveRecord::Base; end

  def up
    # 모든 템플릿에 대해 로컬 이미지 경로 매핑
    # preview_url 기준으로 image_url 업데이트
    
    mappings = {
      # ========== 뷰티/살롱 ==========
      "/templates/beauty" => "/images/templates/beauty_makeup.png",
      "/templates/nail" => "/images/templates/beauty_makeup.png",
      "/templates/barber" => "/images/templates/beauty_makeup.png",
      
      # ========== 다이닝/F&B ==========
      "/templates/dining" => "/images/templates/dining_omakase.png",
      "/templates/cafe" => "/images/templates/cafe_baguette.png",
      "/templates/burger" => "/images/templates/dining_omakase.png",
      "/templates/wine" => "/images/templates/dining_omakase.png",
      "/templates/salad" => "/images/templates/salad_green.png",
      "/templates/dessert" => "/images/templates/sweetspot_donut.png",
      "/templates/donut" => "/images/templates/sweetspot_donut.png",
      
      # ========== 피트니스/요가 ==========
      "/templates/gym" => "/images/templates/fitness_gym.png",
      "/templates/yoga" => "/images/templates/yoga_flow.png",
      "/templates/sculpt" => "/images/templates/fitness_gym.png",
      
      # ========== 숙박/스테이 ==========
      "/templates/hotel" => "/images/templates/hotel_grand.png",
      "/templates/pension" => "/images/templates/pension_spa.png",
      "/templates/stay" => "/images/templates/cozy_stay.png",
      "/templates/camping" => "/images/templates/camping_tent.png",
      
      # ========== 쇼핑/패션 ==========
      "/templates/shopping" => "/images/templates/shopping_new_arrivals.png",
      "/templates/ecommerce" => "/images/templates/the_avenue.png",
      "/templates/cloth" => "/images/templates/the_avenue.png",
      "/templates/shoe" => "/images/templates/urban_kicks.png",
      "/templates/bag" => "/images/templates/leather_atelier.png",
      
      # ========== 기업/스타트업 ==========
      "/templates/corporate" => "/images/templates/corporate_office.png",
      "/templates/startup" => "/images/templates/novus_saas.png",
      "/templates/agency" => "/images/templates/corporate_office.png",
      "/templates/consulting" => "/images/templates/corporate_office.png",
      
      # ========== 병원/의료 ==========
      "/templates/medical" => "/images/templates/skin_clinic_hero.png",
      "/templates/dental" => "/images/templates/skin_clinic_hero.png",
      "/templates/vet" => "/images/templates/skin_clinic_hero.png",
      
      # ========== 법률/전문직 ==========
      "/templates/law" => "/images/templates/law_office.png",
      "/templates/tax" => "/images/templates/tax_partner.png",
      
      # ========== 교육/학원 ==========
      "/templates/academy" => "/images/templates/academy_coding.png",
      "/templates/kinder" => "/images/templates/kinder_classroom.png",
      "/templates/study" => "/images/templates/academy_coding.png",
      "/templates/learnhub" => "/images/templates/code_academy.png",
      "/templates/english" => "/images/templates/little_star.png",
      "/templates/artistry" => "/images/templates/minimal_studio.png",
      
      # ========== 공간/스튜디오 ==========
      "/templates/studio" => "/images/templates/minimal_studio.png",
      "/templates/rental" => "/images/templates/minimal_studio.png",
      
      # ========== 플라워/가든 ==========
      "/templates/flower" => "/images/templates/flower_garden.png",
      
      # ========== 포트폴리오 ==========
      "/templates/portfolio" => "/images/templates/portfolio_gallery.png",
      
      # ========== 청소/클리닝 ==========
      "/templates/cleaning" => "/images/templates/cleaning_main.png",
      
      # ========== 금융/재테크 ==========
      "/templates/finance" => "/images/templates/finance_invest.png",
      
      # ========== 펫/반려동물 ==========
      "/templates/petshop" => "/images/templates/flower_garden.png",
      
      # ========== 웨딩 ==========
      "/templates/wedding" => "/images/templates/flower_garden.png"
    }

    updated_count = 0
    mappings.each do |preview_url, image_path|
      template = DesignTemplate.find_by(preview_url: preview_url)
      if template
        puts "✓ #{template.title}: #{image_path}"
        template.update_column(:image_url, image_path)
        updated_count += 1
      end
    end

    puts ""
    puts "=" * 50
    puts "총 #{updated_count}개 템플릿의 image_url을 로컬 경로로 업데이트 완료!"
    puts "=" * 50
  end

  def down
    # 이전 상태로 되돌리기 어려움 (이전 URL 저장 안함)
  end
end
