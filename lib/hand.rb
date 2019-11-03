# frozen_string_literal: true

class Hand
  class Status
    UNKNOWN = 0
    WON = 1
    LOST = 2
    PUSH = 3
  end

  class CountMethod
    SOFT = 0
    HARD = 1
  end

  attr_accessor :cards, :game, :played

  def initialize(game)
    @game = game
    @played = false
    @cards = []
  end

  def deal_card
    cards << game.shoe.next_card
  end

  def blackjack?
    return false if cards.size != 2

    cards.first.ace? && cards.last.ten? || cards.first.ten? && cards.last.ace?
  end
end
