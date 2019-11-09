# frozen_string_literal: true

FactoryBot.define do
  factory :dealer_hand do
    blackjack { nil }
    hide_down_card { true }

    initialize_with { new(blackjack) }
  end
end
