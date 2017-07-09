class Promocode < ApplicationRecord
  belongs_to :promotion

  has_many :discounts
  has_many :redemptions, through: :discounts

  def generate_code
    ('a'..'z').to_a.shuffle[0,8].join
  end
end
