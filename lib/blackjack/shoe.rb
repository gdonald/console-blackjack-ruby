# frozen_string_literal: true

require_relative 'card'

SHOES = {
  1 => :regular,
  2 => :aces,
  3 => :jacks,
  4 => :aces_jacks,
  5 => :sevens,
  6 => :eights
}.freeze

class Shoe
  CARDS_PER_DECK = 52

  attr_accessor :blackjack, :num_decks, :cards

  def initialize(blackjack, num_decks)
    @blackjack = blackjack
    @num_decks = num_decks
    @cards = []
  end

  def needs_to_shuffle?
    return true if cards.size.zero?

    cards_dealt = total_cards - cards.size
    used = cards_dealt / total_cards.to_f * 100.0

    used > Shoe.shuffle_specs[num_decks - 1]
  end

  def shuffle
    7.times { cards.shuffle! }
  end

  def new_regular
    self.cards = []
    num_decks.times do
      (0..3).each do |suit_value|
        (0..12).each do |value|
          cards << Card.new(blackjack, value, suit_value)
        end
      end
    end
    shuffle
  end

  def new_irregular(values = [])
    self.cards = []
    while cards.count < total_cards
      (0..3).each do |suit_value|
        next if cards.count >= total_cards

        values.each do |value|
          cards << Card.new(blackjack, value, suit_value)
        end
      end
    end
    shuffle
  end

  def total_cards
    num_decks * CARDS_PER_DECK
  end

  def new_aces
    new_irregular([0])
  end

  def new_jacks
    new_irregular([10])
  end

  def new_aces_jacks
    new_irregular([0, 10])
  end

  def new_sevens
    new_irregular([6])
  end

  def new_eights
    new_irregular([7])
  end

  def next_card
    cards.shift
  end

  def self.shuffle_specs
    [80, 81, 82, 84, 86, 89, 92, 95]
  end
end
