class Quote < ApplicationRecord
  WORKFLOW_STATUSES = %w[
    received first_call kakao_progress signup_order 
    payment_received in_progress review completed subscription_active
  ].freeze

  belongs_to :user, optional: true
  
  validates :contact_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :message, presence: true
  validates :status, inclusion: { in: %w[pending completed] }
  validates :workflow_status, inclusion: { in: WORKFLOW_STATUSES }
end
