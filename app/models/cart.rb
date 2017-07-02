class Cart < ApplicationRecord
  serialize :items, Array

  def total
    (delivery_total || 0) + (item_total || 0)
  end
  private

end