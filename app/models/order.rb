class Order < ApplicationRecord
  belongs_to :user
  belongs_to :product, optional: true  # 기존 호환성 유지
  belongs_to :agency, optional: true
  has_many :order_items, dependent: :destroy
  has_many :design_templates, through: :order_items

  # 주문 상태
  enum :status, {
    pending: 'pending',           # 결제 대기
    paid: 'paid',                 # 결제 완료
    processing: 'processing',     # 처리 중
    completed: 'completed',       # 완료
    cancelled: 'cancelled',       # 취소
    refunded: 'refunded'          # 환불
  }, default: 'pending'

  # 총액 계산
  def calculate_total
    order_items.sum { |item| item.price * item.quantity }
  end

  # 결제 완료 시 호출되는 로직
  def complete_payment!
    return if paid?

    transaction do
      update!(status: 'paid')
      
      # 템플릿 주문인 경우 에이전시 생성
      if order_items.any? { |oi| oi.design_template_id.present? }
        create_agency_for_user
      end
    end
  end

  private

  def create_agency_for_user
    # 이미 에이전시 소유자라면 추가 생성 여부는 정책에 따라 다름 (여기선 하나만 생성한다고 가정)
    return if user.agency_owner? && Agency.exists?(owner_id: user.id)

    # 기본 에이전시 생성
    agency = Agency.create!(
      name: "#{user.name || 'New'}님의 사이트",
      subdomain: "site-#{SecureRandom.hex(4)}", # 임시 서브도메인
      owner: user,
      parent_agency: user.agency, # 상위 에이전시 연결 (Recursive structure)
      active: false # 관리자가 승인하거나 셋팅 완료후 활성화
    )

    # 유저 권한 업그레이드
    user.update!(role: 'owner')
    
    # 생성된 에이전시를 주문에 연결
    update!(agency: agency)
  end

  # 주문 생성 시 총액 자동 계산
  before_save :set_total_amount, if: :new_record?

  private

  def set_total_amount
    self.total_amount ||= calculate_total
  end
end
