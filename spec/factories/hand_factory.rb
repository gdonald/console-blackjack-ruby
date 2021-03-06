# frozen_string_literal: true

FactoryBot.define do
  factory :hand do
    cards { [] }
    game { nil }
    played { false }

    initialize_with { new(game) }
  end
end
