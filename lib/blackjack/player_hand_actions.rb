# frozen_string_literal: true

module PlayerHandActions
  def can_split?
    return false if stood || blackjack.player_hands.size >= PlayerHand::MAX_PLAYER_HANDS

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
end
