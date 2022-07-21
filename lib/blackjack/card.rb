# frozen_string_literal: true

class Card
  attr_reader :blackjack, :value, :suit

  def initialize(blackjack, value, suit)
    @blackjack = blackjack
    @value = value
    @suit = suit
  end

  def to_s
    return Card.faces[value][suit] if blackjack.face_type == 1

    Card.faces2[value][suit]
  end

  def ace?
    value.zero?
  end

  def ten?
    value > 8
  end

  def self.value(card, count_method, total)
    value = card.value.succ
    value = 10 if value > 9
    return 11 if value == 1 && count_method == :soft && total < 11

    value
  end

  def self.faces
    [%w[🂡 🂱 🃁 🃑], %w[🂢 🂲 🃂 🃒], %w[🂣 🂳 🃃 🃓], %w[🂤 🂴 🃄 🃔],
     %w[🂥 🂵 🃅 🃕], %w[🂦 🂶 🃆 🃖], %w[🂧 🂷 🃇 🃗], %w[🂨 🂸 🃈 🃘],
     %w[🂩 🂹 🃉 🃙], %w[🂪 🂺 🃊 🃚], %w[🂫 🂻 🃋 🃛], %w[🂭 🂽 🃍 🃝],
     %w[🂮 🂾 🃎 🃞], %w[🂠]]
  end

  def self.faces2
    [%w[A♠ A♥ A♣ A♦], %w[2♠ 2♥ 2♣ 2♦],
     %w[3♠ 3♥ 3♣ 3♦], %w[4♠ 4♥ 4♣ 4♦],
     %w[5♠ 5♥ 5♣ 5♦], %w[6♠ 6♥ 6♣ 6♦],
     %w[7♠ 7♥ 7♣ 7♦], %w[8♠ 8♥ 8♣ 8♦],
     %w[9♠ 9♥ 9♣ 9♦], %w[T♠ T♥ T♣ T♦],
     %w[J♠ J♥ J♣ J♦], %w[Q♠ Q♥ Q♣ Q♦],
     %w[K♠ K♥ K♣ K♦], %w[??]]
  end
end
