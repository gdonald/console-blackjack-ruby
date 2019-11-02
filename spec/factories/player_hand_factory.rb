# frozen_string_literal: true

FactoryBot.define do
  factory :player_hand do
    game { nil }
    bet { 500 }
    status { Hand::Status::UNKNOWN }
    payed { false }

    initialize_with { new(game, bet) }
  end
end
