class Like < ApplicationRecord
  belongs_to :user
  belongs_to :design_template

  validates :user_id, uniqueness: { scope: :design_template_id }
end
