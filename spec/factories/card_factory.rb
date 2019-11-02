FactoryBot.define do
  factory :card do
    value { 0 }
    suite_value { 0 }

    trait :two do
      value { 1 }
    end

    trait :ten do
      value { 9 }
    end

    initialize_with { new(value, suite_value) }
  end
end
