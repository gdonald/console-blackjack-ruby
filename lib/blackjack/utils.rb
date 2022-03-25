# frozen_string_literal: true

module Utils
  def save_game
    File.open(SAVE_FILE, 'w') do |file|
      file.puts "#{num_decks}|#{face_type}|#{money}|#{current_bet}"
    end
  end

  def load_game
    return unless File.readable?(SAVE_FILE)

    a = File.read(SAVE_FILE).split('|')
    self.num_decks   = a[0].to_i
    self.face_type   = a[1].to_i
    self.money       = a[2].to_i
    self.current_bet = a[3].to_i
  end

  def clear_draw_hands
    clear
    draw_hands
  end

  def clear_draw_hands_new_num_decks
    clear_draw_hands
    new_num_decks
  end

  def clear_draw_hands_new_deck_type
    clear_draw_hands
    new_deck_type
  end

  def clear_draw_hands_new_face_type
    clear_draw_hands
    new_face_type
  end

  def clear_draw_hands_ask_insurance
    clear_draw_hands
    ask_insurance
  end

  def clear_draw_hands_bet_options
    clear_draw_hands
    draw_bet_options
  end

  def clear_draw_hands_game_options
    clear_draw_hands
    draw_game_options
  end

  def draw_hands_current_hand_action
    draw_hands
    current_player_hand.action?
  end

  def play_dealer_hand
    dealer_hand.play
    draw_hands
    draw_bet_options
  end
end
