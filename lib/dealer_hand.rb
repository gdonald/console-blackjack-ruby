# frozen_string_literal: true

require 'hand'

class DealerHand < Hand
  attr_accessor :game, :hide_down_card

  def initialize(game)
    @game = game
    @hide_down_card = true
  end

  def busted?
    value(::SOFT) > 21
  end

  def value(count_method)
    total = 0

    cards.each_with_index do |card, index|
      next if index == 1 && hide_down_card

      v = card.value > 9 ? 10 : card.value
      v = 11 if count_method == ::SOFT && v == 1 && total < 11
      total += v
    end

    return value(::HARD) if count_method == ::SOFT && total > 21

    total
  end

  def upcard_is_ace?
    cards.first.ace?
  end

  def draw; end
end
