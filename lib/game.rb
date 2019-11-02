# frozen_string_literal: true

class Game
  attr_accessor :shoe, :money, :player_hands, :dealer_hand, :num_decks, :current_bet, :current_player_hand

  def initialize
    @num_decks = 1
    @money = 10_000
    @current_bet = 500

    load_game

    @shoe = Shoe.new(num_decks)
    @dealer_hand = DealerHand.new(self)
    @current_player_hand = 0
    @player_hands = []
  end

  def load_game; end

  def all_bets
    player_hands.inject(0) { |sum, player_hand| sum + player_hand.bet }
  end

  def ask_insurance; end

  def clear; end

  def deal_new_hand
    shoe.new_regular! if shoe.needs_to_shuffle?
  end
end
