class Purchase < ApplicationRecord
  belongs_to :user, optional: true
  serialize :product_names, coder: JSON
end
