# frozen_string_literal: true

module PlayerHandDraw
  def draw(index)
    out = String.new(' ')
    out << draw_cards
    out << draw_money(index)
    out << draw_status
    out << "\n\n"
    out
  end

  def draw_status
    case status
    when :lost
      draw_lost_str
    when :won
      draw_won_str
    when :push
      'Push'
    else
      ''
    end
  end

  def draw_lost_str
    busted? ? 'Busted!' : 'Lose!'
  end

  def draw_won_str
    blackjack? ? 'Blackjack!' : 'Won!'
  end

  def draw_money(index)
    out = String.new('')
    out << '-' if status == :lost
    out << '+' if status == :won
    out << '$' << Format.money(bet / 100.0)
    out << ' ⇐' if !played && index == blackjack.current_hand
    out << '  '
    out
  end

  def draw_cards
    out = String.new('')
    out << cards.map { |card| "#{card} " }.join
    out << ' ⇒  ' << value(:soft).to_s << '  '
    out
  end
end
