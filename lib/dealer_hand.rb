# frozen_string_literal: true

require_relative 'hand'

class DealerHand < Hand
  attr_accessor :game, :hide_down_card

  def initialize(game)
    super(game)
    @hide_down_card = true
  end

  def busted?
    value(Hand::CountMethod::SOFT) > 21
  end

  def value(count_method)
    total = 0
    cards.each_with_index do |card, index|
      next if index == 1 && hide_down_card

      value = card.value + 1
      v = value > 9 ? 10 : value
      v = 11 if count_method == Hand::CountMethod::SOFT && v == 1 && total < 11
      total += v
    end

    if count_method == Hand::CountMethod::SOFT && total > 21
      value(Hand::CountMethod::HARD)
    else
      total
    end
  end

  def upcard_is_ace?
    cards.first.ace?
  end

  def draw
    out = String.new(' ')
    cards.each_with_index do |card, index|
      out << (index == 1 && hide_down_card ? Card.faces[13][0] : card).to_s
      out << ' '
    end
    out << ' ⇒  '
    out << value(Hand::CountMethod::SOFT).to_s
  end
end
