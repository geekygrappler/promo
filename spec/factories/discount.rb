FactoryGirl.define do
  factory :discount do
    association :original_cart, factory: :cart
    association :discounted_cart, factory: :cart
    user_cart_id { original_cart.user_cart_id }
    promocode
  end
end