# frozen_string_literal: true

FactoryBot.define do
  factory :card do
    value { 0 }
    suite { 0 }

    trait :ace do
      value { 0 }
    end

    trait :two do
      value { 1 }
    end

    trait :six do
      value { 5 }
    end

    trait :seven do
      value { 6 }
    end

    trait :eight do
      value { 7 }
    end

    trait :nine do
      value { 8 }
    end

    trait :ten do
      value { 9 }
    end

    initialize_with { new(value, suite) }
  end
end
