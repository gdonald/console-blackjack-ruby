# frozen_string_literal: true

module Draw
  def self.player_hands(blackjack, player_hands)
    out = String.new('')
    player_hands.each_with_index do |player_hand, index|
      out << Draw.player_hand(blackjack, player_hand, index)
    end
    out
  end

  def self.player_hand(blackjack, player_hand, index)
    out = String.new(' ')
    out << Draw.player_hand_cards(player_hand)
    out << Draw.player_hand_money(blackjack, player_hand, index)
    out << Draw.player_hand_status(player_hand)
    out << "\n\n"
    out
  end

  def self.player_hand_status(player_hand)
    case player_hand.status
    when LOST
      player_hand.busted? ? 'Busted!' : 'Lose!'
    when WON
      player_hand.blackjack? ? 'Blackjack!' : 'Won!'
    when PUSH
      'Push'
    else
      ''
    end
  end

  def self.player_hand_money(blackjack, player_hand, index)
    out = String.new('')
    out << '-' if player_hand.status == LOST
    out << '+' if player_hand.status == WON
    out << '$' << Blackjack.format_money(player_hand.bet / 100.0)
    out << ' ⇐' if !player_hand.played && index == blackjack.current_hand
    out << '  '
    out
  end

  def self.player_hand_cards(player_hand)
    out = String.new('')
    out << player_hand.cards.map { |card| "#{card} " }.join
    out << ' ⇒  ' << player_hand.value(SOFT).to_s << '  '
    out
  end
end
