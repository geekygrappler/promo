FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "email#{n}@test.com" }
    password 'Password'
    password_confirmation 'Password'
  end
end