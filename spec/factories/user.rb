FactoryBot.define do
  factory :user do
    sequence(:slack_id) { |i| "INITIAL_SLACK_ID_#{i}" }
  end
end
