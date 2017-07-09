# Discount is a record of two carts, 1. before and 2. after a promocode has been applied to the user supplied cart.
class Discount < ApplicationRecord

  belongs_to :promocode
  # We create a discount record at the time a promocode is priced. We only link the discount to the
  # redemption after the cart has been purchased. Therefore the redemption is optional.
  belongs_to :redemption, optional: true

  belongs_to :original_cart, class_name: 'Cart'
  belongs_to :discounted_cart, class_name: 'Cart'
end
