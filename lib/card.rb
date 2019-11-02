# frozen_string_literal: true

class Card
  attr_reader :value, :suite_value

  def initialize(value, suite_value)
    @value = value
    @suite_value = suite_value
  end

  def to_s
    Card.faces[value][suite_value]
  end

  def ace?
    value.zero?
  end

  def ten?
    value > 8
  end

  def self.faces
    [%w[🂡 🂱 🃁 🃑], %w[🂢 🂲 🃂 🃒], %w[🂣 🂳 🃃 🃓], %w[🂤 🂴 🃄 🃔],
     %w[🂥 🂵 🃅 🃕], %w[🂦 🂶 🃆 🃖], %w[🂧 🂷 🃇 🃗], %w[🂨 🂸 🃈 🃘],
     %w[🂩 🂹 🃉 🃙], %w[🂪 🂺 🃊 🃚], %w[🂫 🂻 🃋 🃛], %w[🂭 🂽 🃍 🃝],
     %w[🂮 🂾 🃎 🃞], %w[🂠]]
  end
end
