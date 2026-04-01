# frozen_string_literal: true

require 'net/http'
require 'json'

# OpenAI DALL-E 3 이미지 생성 서비스
# Google API가 안되면 이거 사용
class DalleGeneratorService
  DALLE_API_URL = 'https://api.openai.com/v1/images/generations'

  def initialize(project_name = '리멘_부산봄꽃전시회_2026')
    @api_key = ENV['OPENAI_API_KEY']
    @output_dir = Rails.root.join('public', 'projects', project_name, 'images')
    FileUtils.mkdir_p(@output_dir)
  end

  # 단일 이미지 생성
  def generate_image(prompt, filename)
    return { error: 'OPENAI_API_KEY가 설정되지 않았습니다' } unless @api_key

    puts "🎨 DALL-E 3 이미지 생성 중: #{filename}"
    puts "📝 프롬프트: #{prompt[0..50]}..."

    uri = URI(DALLE_API_URL)

    request_body = {
      model: 'dall-e-3',
      prompt: prompt,
      n: 1,
      size: '1792x1024', # 16:9 비율에 가장 가까움
      quality: 'hd',
      style: 'natural' # 또는 'vivid'
    }

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Bearer #{@api_key}"
    request.body = request_body.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.read_timeout = 120 # DALL-E는 시간이 걸림
      http.request(request)
    end

    if response.code == '200'
      data = JSON.parse(response.body)
      image_url = data.dig('data', 0, 'url')

      if image_url
        download_and_save(image_url, filename)
        puts "✅ 저장 완료: #{filename}"
        { success: true, path: File.join(@output_dir, filename) }
      else
        { error: 'URL을 찾을 수 없습니다' }
      end
    else
      error_data = JSON.parse(response.body) rescue {}
      { error: "API 오류: #{response.code} - #{error_data['error']['message'] rescue response.body}" }
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

      # API Rate Limit 방지 (DALL-E 3는 분당 5개 제한)
      sleep 15
    end

    {
      total: results.count,
      success: results.count { |r| r[:success] },
      failed: results.count { |r| !r[:success] },
      results: results
    }
  end

  private

  def download_and_save(url, filename)
    uri = URI(url)
    response = Net::HTTP.get_response(uri)

    if response.code == '200'
      filepath = File.join(@output_dir, filename)
      File.binwrite(filepath, response.body)
    else
      raise "이미지 다운로드 실패: #{response.code}"
    end
  end

  def load_priority_prompts
    json_path = Rails.root.join('knowledge-base', 'generated_images', 'image_prompts.json')
    all_prompts = JSON.parse(File.read(json_path))

    # 우선순위 슬라이드 번호
    priority_slides = [1, 3, 4, 11, 12, 27]

    all_prompts.select do |item|
      priority_slides.include?(item['slide_number'])
    end.first(10).map do |item|
      {
        filename: item['filename'],
        prompt: item['korean_prompt']
      }
    end
  end
end
