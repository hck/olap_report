FactoryGirl.define do
  factory :user do
    sequence(:name){|n| "user_#{n}"}
    sequence(:group){|n| "group_#{n}"}
    registered_at { rand((Date.today << 6)..Date.today) }
  end

  factory :fact do
    user
    score { rand(1..10) }
    created_at { rand((Date.today << 6)..Date.today) }
  end
end