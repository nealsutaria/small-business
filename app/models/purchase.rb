class Purchase < ApplicationRecord
  belongs_to :user, optional: true

  serialize :product_details, coder: JSON
end
