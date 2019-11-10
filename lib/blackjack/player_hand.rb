# frozen_string_literal: true

require_relative 'hand'

class PlayerHand < Hand
  MAX_PLAYER_HANDS = 7

  attr_accessor :blackjack, :bet, :status, :payed, :cards, :stood

  def initialize(blackjack, bet)
    super(blackjack)
    @bet = bet
    @status = UNKNOWN
    @payed = false
    @stood = false
  end

  def pay(dealer_hand_value, dealer_busted)
    return if payed

    self.payed = true
    player_hand_value = value(SOFT)

    if player_hand_won?(dealer_busted, dealer_hand_value, player_hand_value)
      pay_won_hand
    elsif player_hand_lost?(dealer_hand_value, player_hand_value)
      collect_lost_hand
    else
      self.status = PUSH
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
    self.status = LOST
  end

  def pay_won_hand
    self.bet *= 1.5 if blackjack?
    blackjack.money += bet
    self.status = WON
  end

  def value(count_method)
    total = cards.inject(0) { |sum, card| sum + Card.value(card, count_method, sum) }

    if count_method == SOFT && total > 21
      value(HARD)
    else
      total
    end
  end

  def done?
    if no_more_actions?
      self.played = true
      collect_busted_hand if !payed && busted?
      true
    else
      false
    end
  end

  def collect_busted_hand
    self.payed = true
    self.status = LOST
    blackjack.money -= bet
  end

  def no_more_actions?
    played || stood || blackjack? || busted? || value(SOFT) == 21 || value(HARD) == 21
  end

  def can_split?
    return false if stood || blackjack.player_hands.size >= MAX_PLAYER_HANDS

    return false if blackjack.money < blackjack.all_bets + bet

    cards.size == 2 && cards.first.value == cards.last.value
  end

  def can_dbl?
    return false if blackjack.money < blackjack.all_bets + bet

    !(stood || cards.size != 2 || blackjack?)
  end

  def can_stand?
    !(stood || busted? || blackjack?)
  end

  def can_hit?
    !(played || stood || value(HARD) == 21 || blackjack? || busted?)
  end

  def hit
    deal_card

    if done?
      process
    else
      blackjack.draw_hands
      blackjack.current_player_hand.action?
    end
  end

  def dbl
    deal_card

    self.played = true
    self.bet *= 2
    process if done?
  end

  def stand
    self.stood = true
    self.played = true
    process
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
    loop do
      c = Blackjack.getc
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
      break if %w[h s p d].include?(c)
    end
  end

  def clear_draw_hands_action
    blackjack.clear
    blackjack.draw_hands
    action?
  end

  def draw_actions
    out = String.new(' ')
    out << '(H) Hit  ' if can_hit?
    out << '(S) Stand  ' if can_stand?
    out << '(P) Split  ' if can_split?
    out << '(D) Double  ' if can_dbl?
    puts out
  end
end
