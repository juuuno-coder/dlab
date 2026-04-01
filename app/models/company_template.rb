class CompanyTemplate < ApplicationRecord
  # Validations
  validates :name, presence: true
  validates :template_type, presence: true, inclusion: {
    in: %w[company_intro history organization ceo_message portfolio capabilities]
  }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_type, ->(type) { where(template_type: type) }
  scope :ordered, -> { order(:order, :created_at) }

  # Class methods
  def self.template_types
    {
      'company_intro' => '회사 소개',
      'history' => '연혁',
      'organization' => '조직도',
      'ceo_message' => '대표 인사말',
      'portfolio' => '주요 실적',
      'capabilities' => '수행 역량'
    }
  end

  def template_type_name
    self.class.template_types[template_type]
  end
end
