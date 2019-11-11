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
    when LOST
      draw_lost_str
    when WON
      draw_won_str
    when PUSH
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
    out << '-' if status == LOST
    out << '+' if status == WON
    out << '$' << Format.money(bet / 100.0)
    out << ' ⇐' if !played && index == blackjack.current_hand
    out << '  '
    out
  end

  def draw_cards
    out = String.new('')
    out << cards.map { |card| "#{card} " }.join
    out << ' ⇒  ' << value(SOFT).to_s << '  '
    out
  end
end
