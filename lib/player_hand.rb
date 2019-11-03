# frozen_string_literal: true

require_relative 'hand'

class PlayerHand < Hand
  MAX_PLAYER_HANDS = 7

  attr_accessor :game, :bet, :status, :payed, :cards, :stood

  def initialize(game, bet)
    super(game)
    @bet = bet
    @status = Hand::Status::UNKNOWN
    @payed = false
    @stood = false
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
       value(Hand::CountMethod::SOFT) == 21 ||
       value(Hand::CountMethod::HARD) == 21
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

  def hit
    deal_card

    if done?
      process
    else
      game.draw_hands
      game.current_player_hand.action?
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

    if game.more_hands_to_play?
      game.play_more_hands
      return
    end

    game.play_dealer_hand
    game.draw_hands
    game.draw_bet_options
  end

  def process
    if game.more_hands_to_play?
      game.play_more_hands
      return
    end

    game.play_dealer_hand
    game.draw_hands
    game.draw_bet_options
  end

  def draw(index)
    out = String.new(' ')
    cards.each do |card|
      out << "#{card} "
    end

    out << ' ⇒  ' << value(Hand::CountMethod::SOFT).to_s << '  '

    if status == Hand::Status::LOST
      out << '-'
    elsif status == Hand::Status::WON
      out << '+'
    end

    out << '$' << Game.format_money(bet / 100.0)
    out << ' ⇐' if !played && index == game.current_hand
    out << '  '

    if status == Hand::Status::LOST
      out << (busted? ? 'Busted!' : 'Lose!')
    elsif status == Hand::Status::WON
      out << (blackjack? ? 'Blackjack!' : 'Won!')
    elsif status == Hand::Status::PUSH
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
      case Game.getc
      when 'h'
        br = true
        hit
      when 's'
        br = true
        stand
      when 'p'
        br = true
        game.split_current_hand
      when 'd'
        br = true
        dbl
      else
        game.clear
        game.draw_hands
        action?
      end

      break if br
    end
  end
end
