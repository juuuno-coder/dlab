class User < ApplicationRecord
  ROLES = %w[super_admin owner admin user].freeze

  def super_admin?
    role == "super_admin"
  end

  def agency_owner?
    role == "owner"
  end

  def agency_admin?
    role == "admin"
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_one :cart, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_templates, through: :likes, source: :design_template
  has_many :orders # 구매 내역
  has_many :quotes, dependent: :nullify # 상담 내역 (유저 삭제시 상담 내역은 남김)
  belongs_to :agency, optional: true # 소속 에이전시 (없을 수도 있음)

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name   # assuming the user model has a name
      user.image = auth.info.image # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate emails, 
      # uncomment the line below to skip the confirmation emails.
      # user.skip_confirmation!
    end
  end
end
