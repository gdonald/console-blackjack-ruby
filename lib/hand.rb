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

  attr_accessor :cards, :game, :stood, :played

  def initialize(game)
    @game = game
    @played = false
    @stood = false
  end

  def blackjack?
    return false if cards.size != 2

    cards.first.ace? && cards.last.ten? || cards.first.ten? && cards.last.ace?
  end

  # def done?
  #   false
  # end
end
