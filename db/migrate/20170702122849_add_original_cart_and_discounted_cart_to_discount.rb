class AddOriginalCartAndDiscountedCartToDiscount < ActiveRecord::Migration[5.1]
  def change
    add_reference :discounts, :original_cart, index: true
    add_reference :discounts, :discounted_cart, index: true
  end
end
