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
  attr_accessor :num_decks, :cards

  def initialize(num_decks = 1)
    @num_decks = num_decks
    @cards = []
  end

  def needs_to_shuffle?
    return true if cards.size.zero?

    total_cards = num_decks * 52
    cards_dealt = total_cards - cards.size
    used = cards_dealt / total_cards.to_f * 100.0

    Shoe.shuffle_specs.each do |spec|
      return true if used > spec.first && num_decks == spec.last
    end

    false
  end

  def shuffle
    7.times { cards.shuffle! }
  end

  def new_regular
    self.cards = []
    num_decks.times do
      (0..3).each do |suit_value|
        (0..12).each do |value|
          cards << Card.new(value, suit_value)
        end
      end
    end
    shuffle
  end

  def new_aces
    self.cards = []
    (num_decks * 10).times do
      (0..3).each do |suit_value|
        cards << Card.new(0, suit_value)
      end
    end
    shuffle
  end

  def new_jacks
    self.cards = []
    (num_decks * 10).times do
      (0..3).each do |suit_value|
        cards << Card.new(10, suit_value)
      end
    end
    shuffle
  end

  def new_aces_jacks
    self.cards = []
    (num_decks * 10).times do
      (0..3).each do |suit_value|
        cards << Card.new(0, suit_value)
        cards << Card.new(10, suit_value)
      end
    end
    shuffle
  end

  def new_sevens
    self.cards = []
    (num_decks * 10).times do
      (0..3).each do |suit_value|
        cards << Card.new(6, suit_value)
      end
    end
    shuffle
  end

  def new_eights
    self.cards = []
    (num_decks * 10).times do
      (0..3).each do |suit_value|
        cards << Card.new(7, suit_value)
      end
    end
    shuffle
  end

  def next_card
    cards.shift
  end

  def self.shuffle_specs
    [[95, 8],
     [92, 7],
     [89, 6],
     [86, 5],
     [84, 4],
     [82, 3],
     [81, 2],
     [80, 1]]
  end
end
