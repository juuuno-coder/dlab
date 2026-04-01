class Portfolio < ApplicationRecord
  has_one_attached :image
  has_one_attached :mobile_image
  has_rich_text :description
  validates :title, presence: true
end
