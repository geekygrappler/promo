FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "email#{n}@test.com" }
  end
end