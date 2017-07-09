class Redemption < ApplicationRecord
  has_many :discounts
  has_many :promocodes, through: :discounts
end
