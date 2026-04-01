class KnowledgeDocument < ApplicationRecord
  # Attachments
  has_one_attached :document

  # Serialize
  serialize :analysis_result, coder: JSON
  serialize :metadata, coder: JSON

  # Validations
  validates :title, presence: true
  validates :category, presence: true, inclusion: { in: %w[rfp_sample previous_proposal template resource] }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :analyzed, -> { where.not(analyzed_at: nil) }
  scope :pending_analysis, -> { where(analyzed_at: nil) }
  scope :recent_first, -> { order(created_at: :desc) }

  # Category methods
  def self.category_options
    {
      'rfp_sample' => '공고서/제안요청서',
      'previous_proposal' => '기존 제안서',
      'template' => '공통 양식',
      'resource' => '참고 자료'
    }
  end

  def self.category_colors
    {
      'rfp_sample' => 'blue',
      'previous_proposal' => 'purple',
      'template' => 'green',
      'resource' => 'yellow'
    }
  end

  def category_label
    self.class.category_options[category] || category
  end

  def category_color
    self.class.category_colors[category] || 'gray'
  end

  # Analysis status
  def analyzed?
    analyzed_at.present?
  end

  def analysis_status
    analyzed? ? '분석 완료' : '분석 대기'
  end

  # Gemini API 멀티모달 분석
  def analyze_with_gemini
    return { error: '첨부 파일이 없습니다' } unless document.attached?

    service = KnowledgeAnalyzerService.new(self)
    result = service.analyze

    if result[:success]
      update(
        analysis_result: result[:data],
        analyzed_at: Time.current
      )
    end

    result
  end
end
