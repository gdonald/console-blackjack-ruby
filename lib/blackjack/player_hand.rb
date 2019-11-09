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

    if dealer_busted || player_hand_value > dealer_hand_value
      self.bet *= 1.5 if blackjack?
      blackjack.money += bet
      self.status = WON
    elsif player_hand_value < dealer_hand_value
      blackjack.money -= bet
      self.status = LOST
    else
      self.status = PUSH
    end
  end

  def value(count_method)
    total = 0
    cards.each do |card|
      value = card.value + 1
      v = value > 9 ? 10 : value
      v = 11 if count_method == SOFT && v == 1 && total < 11
      total += v
    end

    return value(HARD) if count_method == SOFT && total > 21

    total
  end

  def done?
    if played || stood || blackjack? || busted? ||
       value(SOFT) == 21 ||
       value(HARD) == 21
      self.played = true

      if !payed && busted?
        self.payed = true
        self.status = LOST
        blackjack.money -= bet
      end
      return true
    end

    false
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

  def draw(index)
    out = String.new(' ')
    cards.each do |card|
      out << "#{card} "
    end

    out << ' ⇒  ' << value(SOFT).to_s << '  '

    if status == LOST
      out << '-'
    elsif status == WON
      out << '+'
    end

    out << '$' << Blackjack.format_money(bet / 100.0)
    out << ' ⇐' if !played && index == blackjack.current_hand
    out << '  '

    if status == LOST
      out << (busted? ? 'Busted!' : 'Lose!')
    elsif status == WON
      out << (blackjack? ? 'Blackjack!' : 'Won!')
    elsif status == PUSH
      out << 'Push'
    end

    out << "\n\n"
    out
  end

  def action?
    out = String.new(' ')
    out << '(H) Hit  ' if can_hit?
    out << '(S) Stand  ' if can_stand?
    out << '(P) Split  ' if can_split?
    out << '(D) Double  ' if can_dbl?
    puts out

    loop do
      br = false
      case Blackjack.getc
      when 'h'
        br = true
        hit
      when 's'
        br = true
        stand
      when 'p'
        br = true
        blackjack.split_current_hand
      when 'd'
        br = true
        dbl
      else
        blackjack.clear
        blackjack.draw_hands
        action?
      end

      break if br
    end
  end
end
