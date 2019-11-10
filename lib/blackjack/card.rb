# frozen_string_literal: true

class Card
  attr_reader :value, :suite

  def initialize(value, suite)
    @value = value
    @suite = suite
  end

  def to_s
    Card.faces[value][suite]
  end

  def ace?
    value.zero?
  end

  def ten?
    value > 8
  end

  def self.value(card, count_method, total)
    value = card.value + 1
    v = value > 9 ? 10 : value
    count_method == SOFT && v == 1 && total < 11 ? 11 : v
  end

  def self.faces
    [%w[🂡 🂱 🃁 🃑], %w[🂢 🂲 🃂 🃒], %w[🂣 🂳 🃃 🃓], %w[🂤 🂴 🃄 🃔],
     %w[🂥 🂵 🃅 🃕], %w[🂦 🂶 🃆 🃖], %w[🂧 🂷 🃇 🃗], %w[🂨 🂸 🃈 🃘],
     %w[🂩 🂹 🃉 🃙], %w[🂪 🂺 🃊 🃚], %w[🂫 🂻 🃋 🃛], %w[🂭 🂽 🃍 🃝],
     %w[🂮 🂾 🃎 🃞], %w[🂠]]
  end
end
