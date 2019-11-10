# frozen_string_literal: true

module SplitHand
  def split_current_hand
    if current_player_hand.can_split?
      expand_split_hands
      this_hand = split_hand

      if this_hand.done?
        this_hand.process
      else
        draw_hands_current_hand_action
      end
    else
      draw_hands_current_hand_action
    end
  end

  def split_hand
    this_hand = player_hands[current_hand]
    split_hand = player_hands[current_hand + 1]

    split_hand.cards = []
    split_hand.cards << this_hand.cards.last
    this_hand.cards.pop

    this_hand.cards << shoe.next_card
    this_hand
  end

  def expand_split_hands
    player_hands << PlayerHand.new(self, current_bet)

    x = player_hands.size - 1
    while x > current_hand
      player_hands[x] = player_hands[x - 1].clone
      x -= 1
    end
  end
end
