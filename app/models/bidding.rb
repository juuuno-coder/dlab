class Bidding < ApplicationRecord
  # Attachments
  has_many_attached :documents

  # Serialize
  serialize :selected_template_ids, coder: JSON

  # Validations
  validates :title, presence: true
  validates :status, inclusion: { in: %w[예정 진행중 제출완료 심사중 선정 탈락] }
  validates :progress, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  # Template methods
  def selected_templates
    return [] if selected_template_ids.blank?
    CompanyTemplate.where(id: selected_template_ids).active.ordered
  end

  def theme_color
    slide_theme_color.presence || '#1E40AF'
  end

  def font_family
    slide_font_family.presence || 'Pretendard'
  end

  # Scopes
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :recent_first, -> { order(created_at: :desc) }
  scope :by_deadline, -> { order(Arel.sql("deadline IS NULL, deadline ASC")) }

  # Status methods
  def self.status_options
    %w[예정 진행중 제출완료 심사중 선정 탈락]
  end

  def self.status_colors
    {
      "예정" => "gray",
      "진행중" => "blue",
      "제출완료" => "yellow",
      "심사중" => "purple",
      "선정" => "green",
      "탈락" => "red"
    }
  end

  def status_color
    self.class.status_colors[status] || "gray"
  end

  def progress_color
    case progress
    when 0...30
      "red"
    when 30...70
      "yellow"
    when 70...90
      "blue"
    else
      "green"
    end
  end

  # 제안서 아웃라인 자동 생성
  def generate_proposal_outline
    template = <<~OUTLINE
      # #{title} 제안서 아웃라인

      ## Ⅰ. 제안 개요 (Why & Concept)
      ### 1. 사업의 이해
      - 발주처: #{agency}
      - 예산 규모: #{budget}
      - 사업 목적 및 배경

      ### 2. 핵심 추진 전략
      - 전략 1: [RFP 분석 기반]
      - 전략 2: [차별화 포인트]
      - 전략 3: [리스크 관리]

      ## Ⅱ. 사업 수행 계획 (What & How)
      ### 3. 총괄 운영 계획
      - 사업 기간: #{application_period}
      - 추진 체계
      - 일정 관리

      ### 4. 세부 프로그램 기획
      - 프로그램 1:
      - 프로그램 2:
      - 프로그램 3:

      ### 5. 공간 및 시설 계획
      - 동선 계획
      - 시설 배치
      - 시스템 구성

      ## Ⅲ. 홍보 및 안전 관리
      ### 6. 홍보 마케팅 전략
      - 온라인 채널 활용
      - 오프라인 홍보
      - SNS 바이럴

      ### 7. 안전 관리 계획
      - 안전 요원 배치
      - 비상 대응 체계
      - 보험 가입

      ### 8. 민원 대응
      - 민원 접수 체계
      - 사후 관리 방안

      ## Ⅳ. 조직 및 기대효과
      ### 9. 조직 구성 및 인력 계획
      - 총괄 PM:
      - 세부 담당자:
      - 협력 업체: #{partner}

      ### 10. 기대 효과
      - 정량적 효과
      - 정성적 효과
      - 지역 경제 기여

      ---

      💡 **제안 포인트**
      #{winning_strategy.present? ? winning_strategy : "- NotebookLM 분석 결과를 여기에 추가하세요"}
    OUTLINE

    self.proposal_outline = template
    save
  end

  # NotebookLM 스타일 진단/컨설팅 보고서 생성
  def generate_diagnosis
    report = <<~DIAGNOSIS
      # NotebookLM 기반 입찰 전략 수립: #{title}

      ## Step 1: RFP 핵심 키워드 도출

      ### 발주처 핵심 성과 지표(KPI) 3가지
      1. **[KPI 1]**: #{analysis_notes.present? ? "[분석 노트에서 추출]" : "사업의 핵심 목표를 설정하세요"}
      2. **[KPI 2]**: 체계적 관리 및 철저한 안전 수행
      3. **[KPI 3]**: 지역 산업 활성화 및 경제 기여

      ### 반드시 포함되어야 할 필수 과업
      - 실행계획 수립
      - 프로그램(전시·체험·이벤트) 유치 및 진행
      - 온·오프라인 홍보
      - 행사장 시설물 설치 및 철거
      - 안전 및 비상대책 수립

      ---

      ## Step 2: 전년도 개선점 및 타사 벤치마킹 (Winning Point)

      ### 전년도 결과보고서상 문제점 및 민원 사항
      - **문제점 1**: [전년도 이슈 분석 필요]
      - **문제점 2**: [민원 사항 파악 필요]
      - **문제점 3**: [개선 필요 사항]

      ### 차별화 전략 (Winning Point)
      #{winning_strategy.present? ? winning_strategy : "**전략 1**: 효율적 공간 재배치\n**전략 2**: 디지털 시스템 도입\n**전략 3**: 홍보 매체 다변화"}

      ---

      ## Step 3: 슬라이드별 개요 및 핵심 내용

      | 슬라이드 번호 | 제목 | 핵심 내용 |
      |--------------|------|-----------|
      | Slide 1 | #{title}: [서브타이틀] | 행사 비전 및 상징성을 담은 타이틀 제안 |
      | Slide 2 | 사업의 이해 | 발주처의 핵심 니즈 및 사업 취지 분석 |
      | Slide 3 | 추진 전략: 3S 전략 | Special(독창성), Safe(안전), Smart(효율) |
      | Slide 4 | 연간 총괄 운영 계획 | #{application_period} 기간 로드맵 제시 |
      | Slide 5-8 | 세부 프로그램 기획 | 전년도 인기 프로그램 고도화 방안 |
      | Slide 9 | 공간 및 동선 계획 | 관람객 최적 동선 설계 및 존(Zone) 구성 |
      | Slide 10 | 시스템 운영 계획 | 하드웨어 사양 및 기술 구현 방안 |
      | Slide 11 | 홍보 마케팅 전략 | 온·오프라인 통합 홍보 전략 |
      | Slide 12 | 안전 관리 및 비상 대책 | 안전관리 조직 및 긴급 대응 체계 |
      | Slide 13 | 민원 대응 및 사후 관리 | 전년도 민원 해결 방안 및 현장 매뉴얼 |
      | Slide 14 | 조직 및 인력 구성 | 총괄 PM 중심 전담 조직 구성 |
      | Slide 15 | 기대 효과 및 맺음말 | 정량적·정성적 성과 및 지역 기여도 |

      ---

      ## 입찰 제안서 권장 슬라이드 구성 상세 가이드

      ### Ⅰ. 제안 개요 (Why & Concept)
      - **Slide 1 (타이틀)**: 행사의 가치를 계승하면서도 차별성을 강조하는 네이밍 사용
      - **Slide 2 (사업의 이해)**: 발주처의 핵심 고민을 정확히 짚어내는 문제의식 제시
      - **Slide 3 (추진 전략)**: 창의적 기획, 효율적 조성, 즉시성 있는 홍보를 핵심 전략으로 설정

      ### Ⅱ. 사업 수행 계획 (What & How)
      - **Slide 4 (운영 계획)**: 착수일부터 철거까지의 전체 일정 시각화
      - **Slide 5-8 (세부 프로그램)**: 검증된 인기 프로그램 강화 방안 제시
      - **Slide 9 (공간 및 동선)**: 효율적 배치를 위한 존(Zone) 구성도
      - **Slide 10 (시스템)**: 고품질 연출을 위한 장비 계획

      ### Ⅲ. 홍보 및 안전 관리 (Safety & Viral)
      - **Slide 11 (홍보 마케팅)**: SNS 채널 협업 및 영상 홍보 전략
      - **Slide 12 (안전 관리)**: 구체적 사고 예방 대책 및 단계별 대응 시나리오
      - **Slide 13 (민원 대응)**: 전년도 문제 해결을 위한 개선 방안

      ### Ⅳ. 사업 관리 및 제안사 현황 (Who)
      - **Slide 14 (조직 및 인력)**: PM의 경력 및 전담 인력의 전문성 부각
      - **Slide 15 (기대 효과)**: 시민 만족도 향상 및 지역 상생 효과를 정량적으로 제시

      ---

      **생성 일시**: #{Time.current.strftime("%Y년 %m월 %d일 %H:%M")}
      **분석 기준**: #{analysis_notes.present? ? "NotebookLM 분석 결과 반영" : "기본 템플릿"}
    DIAGNOSIS

    self.diagnosis_report = report
    save
  end

  # 피그마 연동 가능한 HTML 슬라이드 생성
  def generate_slides_html
    html = <<~HTML
      <!DOCTYPE html>
      <html lang="ko">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>#{title} - 제안서 슬라이드</title>
        <style>
          * { margin: 0; padding: 0; box-sizing: border-box; }
          body { font-family: 'Pretendard', -apple-system, sans-serif; background: #f5f5f5; }
          .slide {
            width: 1920px;
            height: 1080px;
            background: white;
            margin: 20px auto;
            padding: 80px 120px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            page-break-after: always;
          }
          .slide-header { border-bottom: 4px solid #1E40AF; padding-bottom: 20px; margin-bottom: 60px; }
          .slide-number { color: #1E40AF; font-size: 24px; font-weight: 700; }
          .slide-title { font-size: 64px; font-weight: 800; color: #111; margin-top: 20px; line-height: 1.3; }
          .slide-subtitle { font-size: 32px; color: #666; margin-top: 20px; }
          .slide-content { font-size: 28px; line-height: 1.8; color: #333; }
          .slide-content h2 { font-size: 48px; margin-top: 40px; margin-bottom: 30px; color: #1E40AF; }
          .slide-content h3 { font-size: 36px; margin-top: 30px; margin-bottom: 20px; color: #3B82F6; }
          .slide-content ul { margin-left: 40px; margin-top: 20px; }
          .slide-content li { margin-bottom: 20px; }
          .highlight { background: linear-gradient(180deg, rgba(30,64,175,0) 50%, rgba(30,64,175,0.2) 50%); padding: 0 8px; }
          .footer { position: absolute; bottom: 60px; right: 120px; font-size: 20px; color: #999; }
          .cover { background: linear-gradient(135deg, #1E40AF 0%, #3B82F6 100%); color: white; display: flex; flex-direction: column; justify-content: center; align-items: center; text-align: center; }
          .cover .slide-title { color: white; font-size: 96px; }
          .cover .slide-subtitle { color: rgba(255,255,255,0.9); font-size: 48px; }
          table { width: 100%; border-collapse: collapse; margin-top: 30px; }
          th, td { border: 2px solid #E5E7EB; padding: 20px; text-align: left; font-size: 24px; }
          th { background: #1E40AF; color: white; font-weight: 700; }
          .strategy-box { background: #F0F9FF; border-left: 6px solid #1E40AF; padding: 30px; margin: 20px 0; border-radius: 8px; }
        </style>
      </head>
      <body>

        <!-- Slide 1: 표지 -->
        <div class="slide cover">
          <div class="slide-title">#{title}</div>
          <div class="slide-subtitle">#{agency} 입찰 제안서</div>
          <div style="margin-top: 80px; font-size: 32px; opacity: 0.9;">
            제안사: #{partner || '디어스'}<br>
            제안일: #{Time.current.strftime("%Y년 %m월 %d일")}
          </div>
        </div>

        <!-- Slide 2: 사업의 이해 -->
        <div class="slide">
          <div class="slide-header">
            <div class="slide-number">02</div>
            <div class="slide-title">사업의 이해</div>
          </div>
          <div class="slide-content">
            <h3>발주처 정보</h3>
            <ul>
              <li><strong>기관명:</strong> #{agency}</li>
              <li><strong>예산 규모:</strong> #{budget}</li>
              <li><strong>사업 기간:</strong> #{application_period}</li>
            </ul>

            <h3 style="margin-top: 60px;">사업 목적 및 배경</h3>
            <div class="strategy-box">
              #{description.present? ? description.gsub("\n", "<br>") : "발주처의 핵심 니즈와 사업 취지를 기술합니다."}
            </div>
          </div>
          <div class="footer">#{partner || '디어스'}</div>
        </div>

        <!-- Slide 3: 추진 전략 -->
        <div class="slide">
          <div class="slide-header">
            <div class="slide-number">03</div>
            <div class="slide-title">핵심 추진 전략</div>
            <div class="slide-subtitle">3S 전략: Special · Safe · Smart</div>
          </div>
          <div class="slide-content">
            <h3>🎯 전략 1: Special (독창적 기획)</h3>
            <p>차별화된 콘텐츠와 혁신적인 프로그램 구성</p>

            <h3 style="margin-top: 50px;">🛡️ 전략 2: Safe (철저한 안전)</h3>
            <p>안전사고 제로(Zero) 달성을 위한 체계적 관리</p>

            <h3 style="margin-top: 50px;">📱 전략 3: Smart (효율적 홍보)</h3>
            <p>온·오프라인 통합 마케팅 및 실시간 소통</p>
          </div>
          <div class="footer">#{partner || '디어스'}</div>
        </div>

        <!-- Slide 4: 총괄 운영 계획 -->
        <div class="slide">
          <div class="slide-header">
            <div class="slide-number">04</div>
            <div class="slide-title">총괄 운영 계획</div>
          </div>
          <div class="slide-content">
            <table>
              <thead>
                <tr>
                  <th>단계</th>
                  <th>기간</th>
                  <th>주요 과업</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>착수 및 기획</td>
                  <td>1개월차</td>
                  <td>실행계획 수립, TF팀 구성</td>
                </tr>
                <tr>
                  <td>프로그램 유치</td>
                  <td>2~3개월차</td>
                  <td>전시·체험 프로그램 섭외</td>
                </tr>
                <tr>
                  <td>홍보 및 준비</td>
                  <td>4개월차</td>
                  <td>온·오프라인 홍보, 시설 설치</td>
                </tr>
                <tr>
                  <td>행사 진행</td>
                  <td>#{application_period}</td>
                  <td>현장 운영 및 안전 관리</td>
                </tr>
                <tr>
                  <td>철거 및 정산</td>
                  <td>행사 종료 후 2주</td>
                  <td>시설 철거, 결과보고서 작성</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div class="footer">#{partner || '디어스'}</div>
        </div>

        <!-- Slide 5: 승리 전략 -->
        <div class="slide">
          <div class="slide-header">
            <div class="slide-number">05</div>
            <div class="slide-title">차별화 전략 (Winning Point)</div>
          </div>
          <div class="slide-content">
            <div class="strategy-box" style="font-size: 26px; line-height: 2;">
              #{winning_strategy.present? ? winning_strategy.gsub("\n", "<br>") : "
                <strong>강점 1:</strong> 협력사 #{partner}와의 시너지<br><br>
                <strong>강점 2:</strong> 전년도 성공 사례 기반 개선 방안<br><br>
                <strong>강점 3:</strong> 체계적 안전 관리 시스템<br><br>
                <strong>차별화 포인트:</strong> 디지털 전환 및 스마트 운영
              "}
            </div>
          </div>
          <div class="footer">#{partner || '디어스'}</div>
        </div>

        <!-- Slide 6: 기대 효과 -->
        <div class="slide">
          <div class="slide-header">
            <div class="slide-number">06</div>
            <div class="slide-title">기대 효과</div>
          </div>
          <div class="slide-content">
            <h3>💎 정량적 효과</h3>
            <ul>
              <li>예상 관람객: <span class="highlight">XX만 명 이상</span></li>
              <li>지역 경제 기여: <span class="highlight">XX억 원 이상</span></li>
              <li>SNS 도달: <span class="highlight">XX만 회 이상</span></li>
            </ul>

            <h3 style="margin-top: 60px;">🌟 정성적 효과</h3>
            <ul>
              <li>시민 정서 함양 및 문화 향유 기회 제공</li>
              <li>지역 브랜드 가치 제고 및 관광 활성화</li>
              <li>지역 산업과의 상생 협력 모델 구축</li>
            </ul>
          </div>
          <div class="footer">#{partner || '디어스'}</div>
        </div>

        <!-- Slide 7: 조직 구성 -->
        <div class="slide">
          <div class="slide-header">
            <div class="slide-number">07</div>
            <div class="slide-title">조직 구성 및 인력 계획</div>
          </div>
          <div class="slide-content">
            <table>
              <thead>
                <tr>
                  <th>역할</th>
                  <th>담당자</th>
                  <th>주요 업무</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>총괄 PM</td>
                  <td>#{assignee || '[담당자명]'}</td>
                  <td>사업 총괄, 의사결정</td>
                </tr>
                <tr>
                  <td>기획팀</td>
                  <td>팀장 외 2명</td>
                  <td>프로그램 기획, 콘텐츠 개발</td>
                </tr>
                <tr>
                  <td>운영팀</td>
                  <td>팀장 외 5명</td>
                  <td>현장 운영, 시설 관리</td>
                </tr>
                <tr>
                  <td>홍보팀</td>
                  <td>팀장 외 2명</td>
                  <td>마케팅, SNS 운영</td>
                </tr>
                <tr>
                  <td>협력사</td>
                  <td>#{partner}</td>
                  <td>전문 분야 지원</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div class="footer">#{partner || '디어스'}</div>
        </div>

        <!-- Slide 8: 맺음말 -->
        <div class="slide cover">
          <div class="slide-title" style="font-size: 72px; margin-bottom: 60px;">감사합니다</div>
          <div style="font-size: 36px; line-height: 2; opacity: 0.9;">
            <strong>#{title}</strong><br>
            성공적인 사업 수행을 약속드립니다
          </div>
          <div style="margin-top: 100px; font-size: 28px;">
            제안사: #{partner || '디어스'}<br>
            문의: #{assignee || '담당자'}<br>
            #{Time.current.strftime("%Y년 %m월 %d일")}
          </div>
        </div>

      </body>
      </html>
    HTML

    self.slides_html = html
    save
  end
end
