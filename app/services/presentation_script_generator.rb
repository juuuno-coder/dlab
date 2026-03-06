require 'net/http'
require 'json'
require 'uri'

class PresentationScriptGenerator
  GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent"

  def initialize(bidding)
    @bidding = bidding
    @api_key = ENV['GEMINI_API_KEY']
  end

  def generate
    raise "GEMINI_API_KEY not set" if @api_key.blank?

    # 1. 작성 지침 로드
    guidelines = load_guidelines

    # 2. 입력 데이터 준비
    input_data = prepare_input_data

    # 3. 프롬프트 생성
    prompt = build_prompt(guidelines, input_data)

    # 4. Gemini API 호출
    response = call_gemini_api(prompt)

    # 5. 결과 파싱
    parse_response(response)
  end

  private

  def load_guidelines
    guidelines_path = Rails.root.join('knowledge-base', 'templates', 'limen-bidding', '발표대본_작성지침.md')
    if File.exist?(guidelines_path)
      File.read(guidelines_path)
    else
      "# 발표대본 작성 지침\n\n1. 사실 기반 작성\n2. ** 볼드 제거\n3. AI스러운 표현 지양\n4. 무기명 발표\n5. 약한 표현 제거\n6. 전문가 톤\n7. 과장 금지\n8. 자연스러운 전환\n9. 긍정적 표현\n10. 참고는 구조만"
    end
  end

  def prepare_input_data
    {
      proposal: @bidding.proposal_content || "제안서 내용 없음",
      rfp: @bidding.rfp_content || "공고문 내용 없음",
      task_order: @bidding.task_order_content || "과업지시서 내용 없음",
      reference_scripts: load_reference_scripts
    }
  end

  def build_prompt(guidelines, data)
    <<~PROMPT
      당신은 입찰 제안발표 대본 작성 전문가입니다.

      ## 작성 지침 (엄격히 준수)
      #{guidelines}

      ## 입력 데이터

      ### 제안서 내용
      #{data[:proposal]}

      ### 공고문
      #{data[:rfp]}

      ### 과업지시서
      #{data[:task_order]}

      ### 참고 대본 (흐름만 참고, 내용 복사 금지)
      #{data[:reference_scripts]}

      ---

      **중요**: 위 작성 지침 10가지를 반드시 준수하세요.

      다음 구조로 20분 발표대본 + 10분 Q&A를 작성하세요:

      1. 인사말 및 제안개요 (2분)
      2. 전문성과 유사 실적 (2분)
      3. 사업 비전 및 추진전략 (3분)
      4. 4가지 차별화 포인트 (5분)
      5. 세부 프로그램 (3분)
      6. 사업관리 및 안전대책 (3분)
      7. 홍보전략 (2분)
      8. 성과 및 사후관리 (1분)
      9. 예산 집행 계획 (1분)
      10. 마무리 (1분)
      11. 질의응답 대비 (참고용)

      마크다운 형식으로 작성하세요.
      ** 볼드는 절대 사용하지 마세요.
      제안서의 실제 내용만 사용하세요.
    PROMPT
  end

  def call_gemini_api(prompt)
    uri = URI.parse("#{GEMINI_API_URL}?key=#{@api_key}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 120 # 2분 타임아웃

    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = 'application/json'

    request.body = {
      contents: [
        {
          parts: [
            { text: prompt }
          ]
        }
      ],
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 8192,
        topP: 0.95,
        topK: 40
      }
    }.to_json

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      raise "Gemini API error: #{response.code} - #{response.body}"
    end

    JSON.parse(response.body)
  end

  def parse_response(response)
    text = response.dig('candidates', 0, 'content', 'parts', 0, 'text')

    if text.nil?
      raise "No text in Gemini response: #{response.inspect}"
    end

    text
  end

  def load_reference_scripts
    ref_dir = Rails.root.join('knowledge-base', 'templates', 'limen-bidding', 'reference')
    scripts = []

    if Dir.exist?(ref_dir)
      Dir.glob(File.join(ref_dir, '*.md')).each do |file|
        scripts << File.read(file)
      end
    end

    if scripts.empty?
      "참고 대본 없음"
    else
      scripts.join("\n\n---\n\n")
    end
  end
end
