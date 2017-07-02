# Discount is a record of two carts, 1. before and 2. after a promocode has been applied to the user supplied cart.
class Discount < ApplicationRecord
  belongs_to :promocode
  belongs_to :original_cart, class_name: 'Cart'
  belongs_to :discounted_cart, class_name: 'Cart'
end
