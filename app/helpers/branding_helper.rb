module BrandingHelper
  DEFAULT_BRANDING = {
    "brand_name" => "디어스",
    "company_name" => "디어스(D.US)",
    "tagline" => "비싼 홈페이지? NO! 돈 벌어주는 홈페이지!",
    "sub_tagline" => "요금제로 초기 개발비 부담은 낮추고, 주력 사업에 집중하세요!",
    "hero_stats" => [
      { "number" => "30+", "label" => "템플릿 선택" },
      { "number" => "3+", "label" => "플랜 선택" },
      { "number" => "맞춤형", "label" => "개발 서비스" },
      { "number" => "안정적인", "label" => "유지보수" }
    ],
    "why_title" => "왜 디어스일까요?",
    "why_subtitle" => "차별화된 전문성과 경험으로 여러분과 함께 성공합니다!",
    "primary_color" => "#00a859",
    "primary_dark" => "#008a47",
    "accent_color" => "#00d670",
    "contact_email" => "duscontactus@gmail.com",
    "meta_description" => "AI 기술과 창의적인 디자인으로 비즈니스의 성공을 이끄는 프리미엄 개발 에이전시입니다.",
    "meta_keywords" => "웹개발, 앱개발, AI개발, UI/UX디자인, 개발에이전시, 디어스, D.US, 홈페이지제작",
    "logo" => "logo.png",
    "copyright" => "디어스(D.US)"
  }.freeze

  def branding
    @_branding ||= if @current_agency&.settings.present?
      DEFAULT_BRANDING.merge(@current_agency.settings)
    else
      DEFAULT_BRANDING
    end
  end
end
