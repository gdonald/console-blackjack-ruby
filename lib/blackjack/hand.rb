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
    cards.size == 2 && value(:soft) == 21
  end

  def value(count_method, hide_first_card: false)
    total = 0
    cards.each_with_index do |card, index|
      next if index.zero? && hide_first_card

      total += Card.value(card, count_method, total)
    end

    return value(:hard, hide_first_card:) if count_method == :soft && total > 21

    total
  end
end
