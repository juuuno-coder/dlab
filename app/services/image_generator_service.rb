# frozen_string_literal: true

require 'net/http'
require 'json'

# 이미지 생성 서비스
# Google Imagen 3 API 또는 Unsplash API 사용
class ImageGeneratorService
  # Google Imagen API (Vertex AI 필요 시)
  IMAGEN_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models'

  # Unsplash API (무료 대체)
  UNSPLASH_API_URL = 'https://api.unsplash.com/search/photos'

  def initialize
    @gemini_api_key = ENV['GOOGLE_GENERATIVE_AI_API_KEY']
    @unsplash_api_key = ENV['UNSPLASH_ACCESS_KEY'] # 선택사항
  end

  # 이미지 프롬프트를 영문으로 최적화 (Gemini 사용)
  def optimize_prompt(korean_prompt)
    return { error: 'API 키가 설정되지 않았습니다' } unless @gemini_api_key

    prompt = <<~PROMPT
      다음 한글 이미지 생성 프롬프트를 영문으로 번역하고,
      DALL-E 3 또는 Midjourney에 최적화된 프롬프트로 개선해주세요.

      원본 프롬프트:
      #{korean_prompt}

      요구사항:
      - 영문 번역
      - 구체적인 시각적 디테일 추가
      - 스타일, 조명, 구도 명시
      - 100단어 이내

      JSON 형식으로 출력:
      {
        "english_prompt": "...",
        "style_tags": ["..."],
        "keywords": ["..."]
      }
    PROMPT

    begin
      response = call_gemini_text(prompt)
      JSON.parse(extract_json(response))
    rescue StandardError => e
      { error: e.message }
    end
  end

  # Unsplash에서 관련 이미지 검색 (무료 대체)
  def search_unsplash(query, count: 1)
    return { error: 'Unsplash API 키가 없습니다' } unless @unsplash_api_key

    uri = URI(UNSPLASH_API_URL)
    params = {
      query: query,
      per_page: count,
      orientation: 'landscape',
      content_filter: 'high'
    }
    uri.query = URI.encode_www_form(params)

    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Client-ID #{@unsplash_api_key}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response.code == '200'
      data = JSON.parse(response.body)
      {
        success: true,
        images: data['results'].map do |img|
          {
            id: img['id'],
            url: img['urls']['regular'],
            download_url: img['urls']['full'],
            description: img['description'],
            photographer: img['user']['name'],
            photographer_url: img['user']['links']['html']
          }
        end
      }
    else
      { error: "Unsplash API 오류: #{response.code}" }
    end
  rescue StandardError => e
    { error: e.message }
  end

  # 이미지 다운로드 및 저장
  def download_image(url, filename)
    uri = URI(url)
    response = Net::HTTP.get_response(uri)

    if response.code == '200'
      File.binwrite(filename, response.body)
      { success: true, path: filename }
    else
      { error: "다운로드 실패: #{response.code}" }
    end
  rescue StandardError => e
    { error: e.message }
  end

  # 42개 슬라이드용 이미지 일괄 생성 가이드
  def generate_slide_images(slide_planning_fe_path)
    fe_planning = JSON.parse(File.read(slide_planning_fe_path))
    slides = fe_planning['슬라이드_비주얼_설계']

    results = []
    slides.each do |slide|
      prompt = slide['gemini_이미지_프롬프트']
      next if prompt.nil? || prompt == '필요 없음' || prompt.is_a?(String) && prompt.include?('필요 없음')

      # 배열인 경우 (여러 이미지)
      prompts = prompt.is_a?(Array) ? prompt : [prompt]

      prompts.each_with_index do |p, idx|
        optimized = optimize_prompt(p)

        results << {
          slide_number: slide['슬라이드_번호'],
          slide_title: slide['슬라이드_제목'],
          image_index: idx,
          korean_prompt: p,
          english_prompt: optimized['english_prompt'],
          filename: "slide_#{slide['슬라이드_번호']}_#{idx + 1}.png"
        }
      end
    end

    results
  end

  private

  def call_gemini_text(prompt)
    uri = URI("#{IMAGEN_API_URL}/gemini-2.0-flash-exp:generateContent?key=#{@gemini_api_key}")

    request_body = {
      contents: [
        {
          parts: [{ text: prompt }]
        }
      ],
      generationConfig: {
        temperature: 0.7,
        topP: 0.8,
        maxOutputTokens: 2048
      }
    }

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = request_body.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    raise "API 오류: #{response.code}" unless response.code == '200'

    data = JSON.parse(response.body)
    data.dig('candidates', 0, 'content', 'parts', 0, 'text')
  end

  def extract_json(text)
    # JSON 블록 추출
    json_match = text.match(/```json\s*(.*?)\s*```/m) || text.match(/\{.*\}/m)
    json_match ? json_match[1] || json_match[0] : text
  end
end
