# frozen_string_literal: true

require 'net/http'
require 'json'
require 'base64'

# RFP (Request for Proposal) 분석 서비스
# Gemini 2.0 Flash를 사용하여 공고서를 자동 분석합니다
class RfpAnalyzerService
  GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent'

  def initialize(bidding)
    @bidding = bidding
    @api_key = ENV['GOOGLE_GENERATIVE_AI_API_KEY']
  end

  # 공고서 자동 분석 (텍스트 기반)
  def analyze
    return { error: '공고서 설명이 없습니다' } if @bidding.description.blank?

    prompt = build_analysis_prompt

    begin
      response = call_gemini_api(prompt)
      analysis_text = extract_text_from_response(response)
      parse_and_save_analysis(analysis_text)

      { success: true, analysis: analysis_text }
    rescue StandardError => e
      { error: e.message }
    end
  end

  # 첨부된 문서 이미지 분석 (멀티모달)
  def analyze_with_images
    return { error: '첨부된 문서가 없습니다' } if @bidding.documents.blank?

    # 첫 번째 문서의 이미지를 base64로 변환
    document = @bidding.documents.first
    image_data = document.download
    base64_image = Base64.strict_encode64(image_data)

    prompt = build_image_analysis_prompt

    begin
      response = call_gemini_api_with_image(prompt, base64_image, document.content_type)
      analysis_text = extract_text_from_response(response)
      parse_and_save_analysis(analysis_text)

      { success: true, analysis: analysis_text }
    rescue StandardError => e
      { error: e.message }
    end
  end

  private

  def call_gemini_api(prompt)
    uri = URI("#{GEMINI_API_URL}?key=#{@api_key}")

    request_body = {
      contents: [
        {
          parts: [
            { text: prompt }
          ]
        }
      ],
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 2048
      }
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = request_body.to_json

    response = http.request(request)
    JSON.parse(response.body)
  end

  def call_gemini_api_with_image(prompt, base64_image, mime_type)
    uri = URI("#{GEMINI_API_URL}?key=#{@api_key}")

    request_body = {
      contents: [
        {
          parts: [
            { text: prompt },
            {
              inline_data: {
                mime_type: mime_type,
                data: base64_image
              }
            }
          ]
        }
      ],
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 2048
      }
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = request_body.to_json

    response = http.request(request)
    JSON.parse(response.body)
  end

  def extract_text_from_response(response)
    return '' unless response['candidates']&.any?

    text = ''
    response['candidates'].each do |candidate|
      if candidate.dig('content', 'parts')
        candidate.dig('content', 'parts').each do |part|
          text += part['text'] if part['text']
        end
      end
    end
    text
  end

  def build_analysis_prompt
    <<~PROMPT
      당신은 입찰 제안서 작성 전문가입니다. 다음 공고서를 분석하여 핵심 정보를 추출해주세요.

      **공고서 내용:**
      #{@bidding.description}

      **발주처:** #{@bidding.agency}
      **예산:** #{@bidding.budget}
      **사업 기간:** #{@bidding.application_period}

      다음 항목을 JSON 형식으로 추출해주세요:

      {
        "kpis": ["KPI 1", "KPI 2", "KPI 3"],
        "required_tasks": ["필수 과업 1", "필수 과업 2", "필수 과업 3"],
        "winning_strategies": ["차별화 전략 1", "차별화 전략 2", "차별화 전략 3"],
        "target_metrics": {
          "visitors": "예상 방문객 수",
          "budget_impact": "예산 대비 기대 효과",
          "social_reach": "SNS 도달 목표"
        }
      }

      JSON만 출력하고, 추가 설명은 하지 마세요.
    PROMPT
  end

  def build_image_analysis_prompt
    <<~PROMPT
      당신은 입찰 공고서 이미지를 분석하는 전문가입니다.
      첨부된 공고서 이미지에서 다음 정보를 추출해주세요:

      1. 사업명
      2. 발주처
      3. 예산 규모
      4. 사업 기간
      5. 핵심 과업 (3-5개)
      6. 평가 기준
      7. 제출 서류

      JSON 형식으로 출력해주세요.
    PROMPT
  end

  def parse_and_save_analysis(analysis_text)
    # JSON 파싱 시도
    begin
      # ```json ... ``` 블록에서 JSON 추출
      json_match = analysis_text.match(/```json\s*(.*?)\s*```/m) || analysis_text.match(/\{.*\}/m)
      json_text = json_match ? json_match[1] || json_match[0] : analysis_text

      data = JSON.parse(json_text)

      # analysis_notes에 KPI + 필수 과업 저장
      notes = "## 🎯 핵심 KPI\n"
      data['kpis']&.each_with_index do |kpi, i|
        notes += "#{i + 1}. #{kpi}\n"
      end

      notes += "\n## 📋 필수 과업\n"
      data['required_tasks']&.each do |task|
        notes += "- #{task}\n"
      end

      if data['target_metrics']
        notes += "\n## 📊 목표 지표\n"
        data['target_metrics'].each do |key, value|
          notes += "- #{key}: #{value}\n"
        end
      end

      # winning_strategy에 차별화 전략 저장
      strategies = ""
      data['winning_strategies']&.each_with_index do |strategy, i|
        strategies += "**전략 #{i + 1}**: #{strategy}\n\n"
      end

      @bidding.update(
        analysis_notes: notes,
        winning_strategy: strategies
      )
    rescue JSON::ParserError => e
      # JSON 파싱 실패 시 원문 그대로 저장
      @bidding.update(
        analysis_notes: "## AI 분석 결과\n\n#{analysis_text}\n\n(JSON 파싱 실패: #{e.message})"
      )
    end
  end
end
