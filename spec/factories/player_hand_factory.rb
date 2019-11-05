# frozen_string_literal: true

FactoryBot.define do
  factory :player_hand do
    game { nil }
    bet { 500 }
    status { UNKNOWN }
    payed { false }
    stood { false }

    initialize_with { new(game, bet) }
  end
end
