# frozen_string_literal: true

namespace :proposal do
  desc '제안서 슬라이드 이미지 프롬프트 생성 (Google AI Studio용 영문 변환)'
  task generate_image_prompts: :environment do
    puts "\n🎨 제안서 이미지 프롬프트 생성 시작...\n\n"

    fe_planning_path = Rails.root.join('knowledge-base', 'slide_planning_fe.json')
    unless File.exist?(fe_planning_path)
      puts "❌ 파일을 찾을 수 없습니다: #{fe_planning_path}"
      exit 1
    end

    service = ImageGeneratorService.new
    image_specs = service.generate_slide_images(fe_planning_path)

    # 결과를 JSON과 Markdown 두 형식으로 저장
    output_dir = Rails.root.join('knowledge-base', 'generated_images')
    FileUtils.mkdir_p(output_dir)

    # JSON 저장
    json_output = output_dir.join('image_prompts.json')
    File.write(json_output, JSON.pretty_generate(image_specs))

    # Markdown 가이드 생성
    md_output = output_dir.join('IMAGE_GENERATION_GUIDE.md')
    markdown = generate_markdown_guide(image_specs)
    File.write(md_output, markdown)

    puts "✅ 완료!"
    puts "📁 JSON: #{json_output}"
    puts "📄 가이드: #{md_output}"
    puts "\n총 #{image_specs.count}개 이미지 프롬프트 생성\n"
  end

  desc 'Unsplash에서 관련 이미지 자동 다운로드 (무료 대체)'
  task download_unsplash_images: :environment do
    puts "\n🖼️  Unsplash 이미지 다운로드 시작...\n\n"

    unless ENV['UNSPLASH_ACCESS_KEY']
      puts "⚠️  UNSPLASH_ACCESS_KEY 환경변수가 설정되지 않았습니다."
      puts "📌 https://unsplash.com/developers 에서 무료 API 키 발급"
      exit 1
    end

    # FE 기획 파일 읽기
    fe_planning_path = Rails.root.join('knowledge-base', 'slide_planning_fe.json')
    fe_planning = JSON.parse(File.read(fe_planning_path))

    service = ImageGeneratorService.new
    # 환경변수로 프로젝트명 전달 (기본값: default)
    # 사용법: PROJECT_NAME=리멘_부산봄꽃전시회_2026 rails proposal:download_unsplash_images
    project_name = ENV['PROJECT_NAME'] || 'default'
    output_dir = Rails.root.join('public', 'projects', project_name, 'images')
    FileUtils.mkdir_p(output_dir)

    # 주요 키워드로 이미지 검색
    keywords = [
      { query: 'spring flower festival korea', filename: 'cover_festival.jpg' },
      { query: 'flower topiary garden', filename: 'topiary.jpg' },
      { query: 'flower market korea', filename: 'market.jpg' },
      { query: 'spring garden busan', filename: 'garden.jpg' },
      { query: 'flower exhibition', filename: 'exhibition.jpg' }
    ]

    keywords.each do |item|
      result = service.search_unsplash(item[:query])
      if result[:success] && result[:images].any?
        img_url = result[:images].first[:download_url]
        filepath = output_dir.join(item[:filename])

        download_result = service.download_image(img_url, filepath)
        if download_result[:success]
          puts "✅ #{item[:filename]} - #{result[:images].first[:photographer]}"
        else
          puts "❌ #{item[:filename]} - #{download_result[:error]}"
        end
      end

      sleep 1 # API Rate Limit 준수
    end

    puts "\n✅ 완료! 이미지 저장 위치: #{output_dir}\n"
  end

  private

  def generate_markdown_guide(image_specs)
    <<~MARKDOWN
      # 제안서 이미지 생성 가이드

      ## 📋 개요
      - 총 이미지 개수: **#{image_specs.count}개**
      - 생성 도구: **Google AI Studio (Imagen 3)** 또는 **DALL-E 3**
      - 이미지 규격: **1920x1080 (16:9 비율)**

      ---

      ## 🎨 이미지별 프롬프트

      #{image_specs.map do |spec|
        <<~SPEC
          ### 슬라이드 #{spec[:slide_number]}: #{spec[:slide_title]}

          **파일명**: `#{spec[:filename]}`

          **원본 프롬프트 (한글)**:
          ```
          #{spec[:korean_prompt]}
          ```

          **영문 프롬프트 (AI Studio용)**:
          ```
          #{spec[:english_prompt]}
          ```

          **스타일**: Pastel, Spring Blossom, Bright, Clean

          ---

        SPEC
      end.join("\n")}

      ## 🛠️ 사용 방법

      ### Option 1: Google AI Studio (추천)
      1. [Google AI Studio](https://aistudio.google.com/app/prompts/new_chat) 접속
      2. 이미지 생성 모드 선택
      3. 위 영문 프롬프트 붙여넣기
      4. 생성된 이미지 다운로드 → `public/proposal_images/` 폴더에 저장

      ### Option 2: DALL-E 3 (ChatGPT Plus)
      1. ChatGPT Plus 접속
      2. "Generate an image: [영문 프롬프트]" 입력
      3. 생성된 이미지 다운로드

      ### Option 3: Unsplash (무료 대체)
      ```bash
      # .env 파일에 추가
      UNSPLASH_ACCESS_KEY=your_access_key_here

      # Rake 태스크 실행
      rails proposal:download_unsplash_images
      ```

      ---

      ## 📁 이미지 저장 구조
      ```
      public/
      └── proposal_images/
          ├── slide_1_1.png       # 표지 KEY VISUAL
          ├── slide_4_1.png       # 제5회 성공 사례
          ├── slide_11_1.png      # 조형물 렌더링 1
          └── ...
      ```

      ## 🔄 HTML 파일에 적용
      이미지 저장 후 `2026_부산봄꽃전시회_제안서.html` 파일에서:
      ```html
      <img src="/proposal_images/slide_1_1.png" alt="KEY VISUAL">
      ```

      ---

      생성일: #{Time.now.strftime('%Y-%m-%d %H:%M')}
    MARKDOWN
  end
end
