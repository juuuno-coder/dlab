class AddAcademyTemplates < ActiveRecord::Migration[8.1]
  class DesignTemplate < ActiveRecord::Base; end

  def up
    # 3개의 교육/학원 템플릿 추가
    templates = [
      {
        title: "LearnHub",
        description: "배움에는 경계가 없다. 온라인 강의 플랫폼을 위한 모던한 다크 테마 디자인.",
        category: "academy",
        preview_url: "/templates/learnhub",
        image_url: "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?q=80&w=800",
        is_featured: true
      },
      {
        title: "English Town",
        description: "Speak English With Confidence! 영어 학원을 위한 밝고 친근한 글로벌 디자인.",
        category: "academy",
        preview_url: "/templates/english",
        image_url: "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?q=80&w=800",
        is_featured: false
      },
      {
        title: "Artistry",
        description: "당신 안의 예술을 깨우다. 음악/미술 학원을 위한 고급스러운 갤러리 스타일 디자인.",
        category: "academy",
        preview_url: "/templates/artistry",
        image_url: "https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?q=80&w=800",
        is_featured: false
      }
    ]

    templates.each do |t|
      template = DesignTemplate.find_or_initialize_by(preview_url: t[:preview_url])
      puts "Creating/Updating Academy Template: #{t[:title]}"
      template.update!(
        title: t[:title],
        description: t[:description],
        category: t[:category],
        image_url: t[:image_url],
        is_featured: t[:is_featured]
      )
    end

    puts "Added #{templates.count} academy templates"
  end

  def down
    DesignTemplate.where(preview_url: ["/templates/learnhub", "/templates/english", "/templates/artistry"]).destroy_all
  end
end
