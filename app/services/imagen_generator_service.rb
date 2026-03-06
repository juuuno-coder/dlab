# frozen_string_literal: true

require 'net/http'
require 'json'

# Google Imagen 3 이미지 생성 서비스
# Vertex AI를 통한 이미지 생성
class ImagenGeneratorService
  # Vertex AI Imagen API
  IMAGEN_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/imagen-3.0-generate-001:predict'

  # 대체: Gemini로 시도
  GEMINI_IMAGE_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent'

  def initialize(project_name = '리멘_부산봄꽃전시회_2026')
    @api_key = ENV['GOOGLE_GENERATIVE_AI_API_KEY']
    @output_dir = Rails.root.join('public', 'projects', project_name, 'images')
    FileUtils.mkdir_p(@output_dir)
  end

  # 단일 이미지 생성
  def generate_image(prompt, filename)
    return { error: 'API 키가 없습니다' } unless @api_key

    puts "🎨 이미지 생성 중: #{filename}"
    puts "📝 프롬프트: #{prompt[0..50]}..."

    # Method 1: Gemini API로 시도 (이미지 생성 기능이 있을 수 있음)
    result = try_gemini_image(prompt)

    if result[:success]
      save_image(result[:image_data], filename)
      { success: true, path: File.join(@output_dir, filename) }
    else
      { error: result[:error] }
    end
  rescue StandardError => e
    { error: e.message }
  end

  # 우선순위 10개 이미지 자동 생성
  def generate_priority_images
    priority_prompts = load_priority_prompts
    results = []

    priority_prompts.each_with_index do |item, index|
      puts "\n[#{index + 1}/#{priority_prompts.count}] #{item[:filename]}"

      result = generate_image(item[:prompt], item[:filename])
      results << {
        filename: item[:filename],
        success: result[:success],
        error: result[:error]
      }

      # API Rate Limit 방지
      sleep 2
    end

    {
      total: results.count,
      success: results.count { |r| r[:success] },
      failed: results.count { |r| !r[:success] },
      results: results
    }
  end

  private

  def try_gemini_image(prompt)
    uri = URI("#{GEMINI_IMAGE_URL}?key=#{@api_key}")

    request_body = {
      contents: [
        {
          parts: [
            {
              text: "Generate an image: #{prompt}\n\nImage specifications: 1920x1080, 16:9 aspect ratio, high quality, photorealistic"
            }
          ]
        }
      ],
      generationConfig: {
        temperature: 0.9,
        topP: 0.95,
        maxOutputTokens: 8192
      }
    }

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = request_body.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.read_timeout = 60
      http.request(request)
    end

    if response.code == '200'
      data = JSON.parse(response.body)

      # 이미지 데이터 추출 시도
      image_data = extract_image_data(data)

      if image_data
        { success: true, image_data: image_data }
      else
        { success: false, error: 'Gemini API는 이미지 생성을 지원하지 않습니다' }
      end
    else
      { success: false, error: "API 오류: #{response.code} - #{response.body}" }
    end
  rescue StandardError => e
    { success: false, error: e.message }
  end

  def extract_image_data(response_data)
    # Gemini 응답에서 이미지 데이터 추출 시도
    # Base64 인코딩된 이미지가 있는지 확인
    parts = response_data.dig('candidates', 0, 'content', 'parts')
    return nil unless parts

    parts.each do |part|
      if part['inline_data'] && part['inline_data']['data']
        return part['inline_data']['data']
      end
    end

    nil
  end

  def save_image(base64_data, filename)
    require 'base64'

    image_data = Base64.decode64(base64_data)
    filepath = File.join(@output_dir, filename)

    File.binwrite(filepath, image_data)
    puts "✅ 저장 완료: #{filepath}"
  end

  def load_priority_prompts
    json_path = Rails.root.join('knowledge-base', 'generated_images', 'image_prompts.json')
    all_prompts = JSON.parse(File.read(json_path))

    # 우선순위 슬라이드 번호
    priority_slides = [1, 3, 4, 11, 12, 27]

    all_prompts.select do |item|
      priority_slides.include?(item['slide_number'])
    end.first(10) # 최대 10개
  end
end
