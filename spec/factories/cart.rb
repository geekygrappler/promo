FactoryGirl.define do
  factory :cart do
    item_total 10
    delivery_total 3
    user_cart_id 'testCartId'
  end
end