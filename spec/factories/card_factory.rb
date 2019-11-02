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

    trait :ten do
      value { 9 }
    end

    initialize_with { new(value, suite) }
  end
end
