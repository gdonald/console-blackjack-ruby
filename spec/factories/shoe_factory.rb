# frozen_string_literal: true

FactoryBot.define do
  factory :shoe do
    num_decks { 1 }
    cards { [] }

    trait :new_regular do
      after(:build, &:new_regular)
    end

    initialize_with { new(num_decks) }
  end
end
