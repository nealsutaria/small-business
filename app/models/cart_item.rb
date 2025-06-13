class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :color, presence: true
  validates :size, presence: true
end
