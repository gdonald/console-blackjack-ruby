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
    return true if cards.empty?

    cards_dealt = total_cards - cards.size
    used = cards_dealt / total_cards.to_f * 100.0

    used > Shoe.shuffle_specs[num_decks - 1]
  end

  def shuffle
    7.times { cards.shuffle! }
  end

  def total_cards
    @total_cards ||= num_decks * CARDS_PER_DECK
  end

  def build_deck(values = [])
    self.cards = []
    while cards.count < total_cards
      4.times do |suit|
        next if cards.count >= total_cards

        values.each do |value|
          cards << Card.new(blackjack, value, suit)
        end
      end
    end
    shuffle
  end

  def new_regular
    build_deck((0..12).to_a)
  end

  def new_aces
    build_deck([0])
  end

  def new_jacks
    build_deck([10])
  end

  def new_aces_jacks
    build_deck([0, 10])
  end

  def new_sevens
    build_deck([6])
  end

  def new_eights
    build_deck([7])
  end

  def next_card
    cards.shift
  end

  def self.shuffle_specs
    [80, 81, 82, 84, 86, 89, 92, 95]
  end
end
