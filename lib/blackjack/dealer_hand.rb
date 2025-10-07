# frozen_string_literal: true

require_relative 'hand'

class DealerHand < Hand
  attr_accessor :blackjack, :hide_first_card

  def initialize(blackjack)
    super
    @hide_first_card = true
  end

  def upcard_is_ace?
    cards.last.ace?
  end

  def draw
    out = String.new(' ')
    cards.each_with_index do |card, index|
      out << (index.zero? && hide_first_card ? Card.new(blackjack, 13, 0) : card).to_s
      out << ' '
    end
    out << ' ⇒  ' << value(:soft, hide_first_card:).to_s
  end

  def deal_required_cards
    soft, hard = both_values
    while soft < 18 && hard < 17
      deal_card
      soft, hard = both_values
    end
  end

  def both_values
    [value(:soft, hide_first_card:), value(:hard, hide_first_card:)]
  end

  def play
    playing = blackjack.need_to_play_dealer_hand?
    self.hide_first_card = false if blackjack? || playing
    deal_required_cards if playing
    self.played = true
    blackjack.pay_hands
  end
end
