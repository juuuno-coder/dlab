class FixAetherPreviewUrl < ActiveRecord::Migration[7.1]
  def up
    # AETHER 템플릿의 미리보기 URL이 잘못되어 있거나 라우트에 없는 경로일 수 있음.
    # 확실하게 존재하는 '/templates/corporate' (SaaS/Corporate 스타일)로 연결.
    target = DesignTemplate.where("title LIKE ?", "%AETHER%").first
    if target
      target.update!(preview_url: "/templates/corporate")
      puts "Fixed AETHER preview_url to /templates/corporate"
    else
      puts "AETHER template not found."
    end
  end

  def down
    # 원상복구 불필요 (수정 작업이므로)
  end
end
