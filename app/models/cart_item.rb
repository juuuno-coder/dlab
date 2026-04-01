class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :item, polymorphic: true

  validates :quantity, numericality: { greater_than: 0 }
end
