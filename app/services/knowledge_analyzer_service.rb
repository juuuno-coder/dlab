# frozen_string_literal: true

require 'net/http'
require 'json'
require 'base64'

# 지식 베이스 문서 분석 서비스
# Gemini 2.0 Flash 멀티모달을 사용하여 다양한 문서 형식 분석
class KnowledgeAnalyzerService
  GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent'

  def initialize(knowledge_document)
    @document = knowledge_document
    @api_key = ENV['GOOGLE_GENERATIVE_AI_API_KEY']
  end

  def analyze
    return { error: '첨부 파일이 없습니다' } unless @document.document.attached?

    prompt = build_analysis_prompt

    begin
      # 멀티모달 분석 (이미지/PDF 지원)
      file_data = @document.document.download
      base64_data = Base64.strict_encode64(file_data)

      response = call_gemini_api_with_file(prompt, base64_data, @document.document.content_type)
      analysis_text = extract_text_from_response(response)
      parsed_data = parse_analysis_result(analysis_text)

      { success: true, data: parsed_data, raw: analysis_text }
    rescue StandardError => e
      { error: e.message }
    end
  end

  private

  def call_gemini_api_with_file(prompt, base64_data, mime_type)
    uri = URI("#{GEMINI_API_URL}?key=#{@api_key}")

    request_body = {
      contents: [
        {
          parts: [
            { text: prompt },
            {
              inline_data: {
                mime_type: mime_type,
                data: base64_data
              }
            }
          ]
        }
      ],
      generationConfig: {
        temperature: 0.3,  # 더 정확한 분석을 위해 낮은 temperature
        maxOutputTokens: 4096
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
    case @document.category
    when 'rfp_sample'
      build_rfp_analysis_prompt
    when 'previous_proposal'
      build_proposal_analysis_prompt
    when 'template'
      build_template_analysis_prompt
    when 'resource'
      build_resource_analysis_prompt
    else
      build_general_analysis_prompt
    end
  end

  def build_rfp_analysis_prompt
    <<~PROMPT
      당신은 공공 입찰 전문가입니다. 첨부된 공고서/제안요청서(RFP)를 분석하여 다음 정보를 JSON 형식으로 추출해주세요.

      **분석 항목:**
      1. 발주처 정보 (기관명, 담당부서)
      2. 사업명 및 목적
      3. 예산 규모
      4. 사업 기간
      5. 핵심 과업 (최소 5개)
      6. 평가 기준 (정량/정성)
      7. 제출 서류 목록
      8. 필수 요구사항 (자격, 실적 등)
      9. 가산점 항목
      10. 핵심 키워드 (최소 10개)

      JSON 형식으로 출력하고, 추가 설명은 하지 마세요.

      {
        "agency": "발주처명",
        "department": "담당부서",
        "project_name": "사업명",
        "purpose": "사업 목적",
        "budget": "예산 규모",
        "period": "사업 기간",
        "tasks": ["과업 1", "과업 2", ...],
        "evaluation_criteria": {
          "quantitative": ["정량 기준 1", ...],
          "qualitative": ["정성 기준 1", ...]
        },
        "required_documents": ["서류 1", "서류 2", ...],
        "requirements": ["요구사항 1", ...],
        "bonus_points": ["가산점 1", ...],
        "keywords": ["키워드1", "키워드2", ...]
      }
    PROMPT
  end

  def build_proposal_analysis_prompt
    <<~PROMPT
      당신은 제안서 분석 전문가입니다. 첨부된 기존 제안서를 분석하여 다음 정보를 JSON 형식으로 추출해주세요.

      **분석 항목:**
      1. 제안서 구조 (목차 구성)
      2. 핵심 전략 및 차별화 포인트
      3. 시각화 요소 (차트, 표, 이미지 등)
      4. 사용된 근거 자료
      5. 톤앤매너 (전문적/창의적/보수적 등)
      6. 강점 분석 (잘된 부분)
      7. 개선점 (부족한 부분)
      8. 재사용 가능한 섹션

      JSON 형식으로 출력하고, 추가 설명은 하지 마세요.

      {
        "structure": ["목차 1", "목차 2", ...],
        "strategies": ["전략 1", "전략 2", ...],
        "visualizations": ["시각화 1", ...],
        "references": ["근거 자료 1", ...],
        "tone": "톤앤매너 설명",
        "strengths": ["강점 1", ...],
        "improvements": ["개선점 1", ...],
        "reusable_sections": ["섹션 1", ...]
      }
    PROMPT
  end

  def build_template_analysis_prompt
    <<~PROMPT
      당신은 문서 템플릿 분석 전문가입니다. 첨부된 템플릿을 분석하여 JSON 형식으로 정보를 추출해주세요.

      **분석 항목:**
      1. 템플릿 유형 (회사소개/조직도/안전관리 등)
      2. 주요 섹션 구성
      3. 필수 정보 항목
      4. 스타일 가이드 (색상, 폰트, 레이아웃)
      5. 재사용 방법

      JSON 형식으로 출력하고, 추가 설명은 하지 마세요.

      {
        "template_type": "템플릿 유형",
        "sections": ["섹션 1", "섹션 2", ...],
        "required_fields": ["필드 1", "필드 2", ...],
        "style_guide": {
          "colors": ["색상1", "색상2"],
          "fonts": ["폰트1", "폰트2"],
          "layout": "레이아웃 설명"
        },
        "usage_notes": "재사용 방법"
      }
    PROMPT
  end

  def build_resource_analysis_prompt
    <<~PROMPT
      당신은 참고 자료 분석 전문가입니다. 첨부된 자료를 분석하여 JSON 형식으로 정보를 추출해주세요.

      **분석 항목:**
      1. 자료 유형 (통계/보고서/연구/기사 등)
      2. 핵심 내용 요약
      3. 주요 통계 수치
      4. 인용 가능한 문장
      5. 관련 키워드

      JSON 형식으로 출력하고, 추가 설명은 하지 마세요.

      {
        "resource_type": "자료 유형",
        "summary": "핵심 내용 요약",
        "statistics": ["통계 1", "통계 2", ...],
        "quotable_sentences": ["인용문 1", "인용문 2", ...],
        "keywords": ["키워드1", "키워드2", ...]
      }
    PROMPT
  end

  def build_general_analysis_prompt
    <<~PROMPT
      첨부된 문서를 분석하여 다음 정보를 JSON 형식으로 추출해주세요.

      1. 문서 유형
      2. 핵심 내용 요약
      3. 주요 키워드

      {
        "document_type": "문서 유형",
        "summary": "핵심 내용",
        "keywords": ["키워드1", "키워드2", ...]
      }
    PROMPT
  end

  def parse_analysis_result(analysis_text)
    begin
      # JSON 블록 추출
      json_match = analysis_text.match(/```json\s*(.*?)\s*```/m) || analysis_text.match(/\{.*\}/m)
      json_text = json_match ? (json_match[1] || json_match[0]) : analysis_text

      JSON.parse(json_text)
    rescue JSON::ParserError => e
      # JSON 파싱 실패 시 원문 반환
      {
        'raw_text' => analysis_text,
        'parse_error' => e.message
      }
    end
  end
end
