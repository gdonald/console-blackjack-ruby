# frozen_string_literal: true

require_relative 'hand'
require_relative 'player_hand_actions'
require_relative 'player_hand_draw'

class PlayerHand < Hand
  include PlayerHandDraw
  include PlayerHandActions

  MAX_PLAYER_HANDS = 7

  attr_accessor :blackjack, :bet, :status, :paid, :cards, :stood

  def initialize(blackjack, bet)
    super(blackjack)
    @bet = bet
    @status = :unknown
    @paid = false
    @stood = false
  end

  def pay(dealer_hand_value, dealer_busted)
    return if paid

    self.paid = true
    player_hand_value = value(:soft)

    if player_hand_won?(dealer_busted, dealer_hand_value, player_hand_value)
      pay_won_hand
    elsif player_hand_lost?(dealer_hand_value, player_hand_value)
      collect_lost_hand
    else
      self.status = :push
    end
  end

  def player_hand_lost?(dealer_hand_value, player_hand_value)
    player_hand_value < dealer_hand_value
  end

  def player_hand_won?(dealer_busted, dealer_hand_value, player_hand_value)
    dealer_busted || player_hand_value > dealer_hand_value
  end

  def collect_lost_hand
    blackjack.money -= bet
    self.status = :lost
  end

  def pay_won_hand
    self.bet *= 1.5 if blackjack?
    blackjack.money += bet
    self.status = :won
  end

  def done?
    return false unless no_more_actions?

    self.played = true
    collect_busted_hand if !paid && busted?
    true
  end

  def collect_busted_hand
    self.paid = true
    self.status = :lost
    blackjack.money -= bet
  end

  def no_more_actions?
    played || stood || blackjack? || busted? || value(:soft) == 21 || value(:hard) == 21
  end

  def process
    if blackjack.more_hands_to_play?
      blackjack.play_more_hands
    else
      blackjack.play_dealer_hand
    end
  end

  def action?
    draw_actions
    c = Blackjack.getc($stdin)
    case c
    when 'h'
      hit
    when 's'
      stand
    when 'p'
      blackjack.split_current_hand
    when 'd'
      dbl
    else
      clear_draw_hands_action
    end
  end

  def clear_draw_hands_action
    blackjack.clear
    blackjack.draw_hands
    action?
  end

  def draw_actions
    actions = []
    actions << '(H) Hit'
    actions << '(S) Stand'
    actions << '(P) Split' if can_split?
    actions << '(D) Double' if can_dbl?
    puts " #{actions.join('  ')}"
  end
end
