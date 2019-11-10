# frozen_string_literal: true

module Utils
  def normalize_current_bet
    if current_bet < MIN_BET
      self.current_bet = MIN_BET
    elsif current_bet > MAX_BET
      self.current_bet = MAX_BET
    end

    self.current_bet = money if current_bet > money
  end

  def clear_draw_hands_new_num_decks
    clear
    draw_hands
    new_num_decks
  end

  def clear_draw_hands_new_deck_type
    clear
    draw_hands
    new_deck_type
  end

  def clear_draw_hands_ask_insurance
    clear
    draw_hands
    ask_insurance
  end

  def play_dealer_hand
    dealer_hand.play
    draw_hands
    draw_bet_options
  end

  def draw_hands_current_hand_action
    draw_hands
    current_player_hand.action?
  end

  def clear_draw_hands_bet_options
    clear
    draw_hands
    draw_bet_options
  end

  def clear_draw_hands_game_options
    clear
    draw_hands
    draw_game_options
  end
end