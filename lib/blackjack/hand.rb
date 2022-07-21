# frozen_string_literal: true

class Hand
  attr_accessor :cards, :blackjack, :played

  def initialize(blackjack)
    @blackjack = blackjack
    @played = false
    @cards = []
  end

  def busted?
    value(:soft) > 21
  end

  def deal_card
    cards << blackjack.shoe.next_card
  end

  def blackjack?
    return false if cards.size != 2

    (cards.first.ace? && cards.last.ten?) || (cards.first.ten? && cards.last.ace?)
  end
end
