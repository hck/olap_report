FactoryGirl.define do
  factory :group do
    #name { "group_#{rand(1..3)}" }
    sequence(:name){ |n| "group_#{n}" }
    category { "category_#{rand(1..3) }" }
  end

  factory :user do
    sequence(:name){|n| "user_#{n}"}
    group
    registered_at { rand((Date.today << 6)..Date.today) }
  end

  factory :fact do
    user
    score { rand(1..10) }
    created_at { rand((Date.today << 6)..Date.today) }
  end
end