class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :design_template
end
