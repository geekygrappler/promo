FactoryGirl.define do
  factory :promotion do
    sequence(:name) { |n| "New Promotoin #{n}" }
    start_date { 10.days.ago }
    end_date { 10.day.from_now }
    user
  end
end