FactoryGirl.define do
  factory :promocode do
    sequence(:code) { |n| "xyz#{n}" }
    promotion
  end
end