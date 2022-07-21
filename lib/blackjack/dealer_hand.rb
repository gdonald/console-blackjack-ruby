# frozen_string_literal: true

require_relative 'hand'

class DealerHand < Hand
  attr_accessor :blackjack, :hide_down_card

  def initialize(blackjack)
    super(blackjack)
    @hide_down_card = true
  end

  def value(count_method)
    total = value_for_method(count_method)

    if count_method == :soft && total > 21
      value(:hard)
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
      out << (index.zero? && hide_down_card ? Card.new(blackjack, 13, 0) : card).to_s
      out << ' '
    end
    out << ' ⇒  ' << value(:soft).to_s
  end

  def deal_required_cards
    soft, hard = both_values
    while soft < 18 && hard < 17
      deal_card
      soft, hard = both_values
    end
  end

  def both_values
    [value(:soft), value(:hard)]
  end

  def play
    playing = blackjack.need_to_play_dealer_hand?
    self.hide_down_card = false if blackjack? || playing
    deal_required_cards if playing
    self.played = true
    blackjack.pay_hands
  end

  private

  def value_for_method(count_method)
    total = 0
    cards.each_with_index do |card, index|
      next if index.zero? && hide_down_card

      total += Card.value(card, count_method, total)
    end
    total
  end
end
