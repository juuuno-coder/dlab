class Agency < ApplicationRecord
  belongs_to :owner, class_name: "User"
  belongs_to :parent_agency, class_name: "Agency", optional: true
  has_many :sub_agencies, class_name: "Agency", foreign_key: "parent_agency_id"
  has_many :users # Fans/Members linked to this agency
  has_many :orders # Orders generated via this agency
  
  serialize :settings, type: Hash, coder: JSON
  serialize :admin_ids, type: Array, coder: JSON

  def admins
    User.where(id: admin_ids)
  end

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
end
