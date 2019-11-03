# frozen_string_literal: true

FactoryBot.define do
  factory :dealer_hand do
    game { nil }
    hide_down_card { true }

    initialize_with { new(game) }
  end
end
