# frozen_string_literal: true

UNKNOWN = 0
WON = 1
LOST = 2
PUSH = 3

SOFT = 4
HARD = 5

class Hand
  attr_accessor :cards, :blackjack, :played

  def initialize(blackjack)
    @blackjack = blackjack
    @played = false
    @cards = []
  end

  def busted?
    value(SOFT) > 21
  end

  def deal_card
    cards << blackjack.shoe.next_card
  end

  def blackjack?
    return false if cards.size != 2

    cards.first.ace? && cards.last.ten? || cards.first.ten? && cards.last.ace?
  end
end
