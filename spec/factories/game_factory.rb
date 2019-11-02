# frozen_string_literal: true

FactoryBot.define do
  factory :game do
    shoe { nil }
    money { 10_000 }
    player_hands { [] }
    dealer_hand { nil }
    num_decks { 1 }
    current_bet { 500 }
    current_player_hand { 0 }
  end
end
