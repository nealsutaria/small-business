class Cart < ApplicationRecord
  has_many :cart_items
  has_many :products, through: :cart_items

  before_create :set_secret_id

  private

  def set_secret_id
    self.secret_id = SecureRandom.uuid + DateTime.now.to_i.to_s
  end
end
