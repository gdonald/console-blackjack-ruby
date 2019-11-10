# frozen_string_literal: true

module Format
  def self.money(value)
    format_str = '%.2f'
    format(format_str, value)
  end
end
