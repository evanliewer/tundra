FactoryBot.define do
  factory :demographic do
    association :team
    name { "MyString" }
  end
end
