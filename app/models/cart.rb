class Cart < ApplicationRecord
  serialize :items, Array

  before_save :calculate_cart_total

  def total
    (delivery_total || 0) + (item_total || 0)
  end
  private

end