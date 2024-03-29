# frozen_string_literal: true

FactoryBot.define do
  factory :blackjack do
    shoe { nil }
    money { 10_000 }
    player_hands { [] }
    dealer_hand { nil }
    num_decks { 1 }
    face_type { 1 }
    current_bet { 500 }
    current_hand { 0 }
  end
end
