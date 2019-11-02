# frozen_string_literal: true

require 'hand'

class PlayerHand < Hand
  MAX_PLAYER_HANDS = 7

  attr_accessor :game, :bet, :status, :payed, :cards

  def initialize(game, bet)
    @game = game
    @bet = bet
    @status = Hand::Status::UNKNOWN
    @payed = false
    @cards = []
  end

  def busted?
    value(Hand::CountMethod::SOFT) > 21
  end

  def value(count_method)
    total = 0
    cards.each do |card|
      value = card.value + 1
      v = value > 9 ? 10 : value
      v = 11 if count_method == Hand::CountMethod::SOFT && v == 1 && total < 11
      total += v
    end

    return value(Hand::CountMethod::HARD) if count_method == Hand::CountMethod::SOFT && total > 21

    total
  end

  def done?
    if played || stood || blackjack? || busted? ||
       value(Hand::CountMethod::SOFT) == 21 || value(Hand::CountMethod::HARD) == 21
      self.played = true

      if !payed && busted?
        self.payed = true
        self.status = Hand::Status::LOST
        game.money -= bet
      end
      return true
    end

    false
  end

  def can_split?
    return false if stood || game.player_hands.size >= MAX_PLAYER_HANDS

    return false if game.money < game.all_bets + bet

    cards.size == 2 && cards.first.value == cards.last.value
  end

  def can_dbl?
    return false if game.money < game.all_bets + bet

    !(stood || cards.size != 2 || blackjack?)
  end

  def can_stand?
    !(stood || busted? || blackjack?)
  end

  def can_hit?
    !(played || stood || value(Hand::CountMethod::HARD) == 21 || blackjack? || busted?)
  end

  def hit!
    deal_card

    if done?
      process
      return
    end

    game.draw_hands
    game.current_player_hand.get_action
  end

  def dbl!; end

  def stand!; end

  def process; end

  def draw(index); end
end
