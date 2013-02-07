FactoryGirl.define do
  factory :group do
    name { "category_#{rand(1..3)}" }
  end

  factory :user do
    sequence(:name){|n| "user_#{n}"}
    group { FactoryGirl.create_list(:group, 3).sample }
    registered_at { rand((Date.today << 6)..Date.today) }
  end

  factory :fact do
    user
    score { rand(1..10) }
    created_at { rand((Date.today << 6)..Date.today) }
  end
end