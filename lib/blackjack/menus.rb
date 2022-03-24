# frozen_string_literal: true

module Menus
  def draw_game_options
    puts ' (N) Number of Decks  (T) Deck Type  (F) Face Type  (B) Back'
    loop do
      c = Blackjack.getc
      case c
      when 'n'
        clear_draw_hands_new_num_decks
      when 't'
        clear_draw_hands_new_deck_type
        clear_draw_hands_bet_options
      when 'f'
        clear_draw_hands_new_face_type
        clear_draw_hands_bet_options
      when 'b'
        clear_draw_hands_bet_options
      else
        clear_draw_hands_game_options
      end
      break if %w[n t b f].include?(c)
    end
  end

  def new_deck_type
    puts ' (1) Regular  (2) Aces  (3) Jacks  (4) Aces & Jacks  (5) Sevens  (6) Eights'
    loop do
      c = Blackjack.getc.to_i
      case c
      when (1..6)
        shoe.send("new_#{SHOES[c]}")
      else
        clear_draw_hands_new_deck_type
      end
      break if (1..6).include?(c)
    end
  end

  def new_face_type
    puts ' (1) 🂡  (2) A♠'
    loop do
      c = Blackjack.getc.to_i
      case c
      when (1..2)
        self.face_type = c
      else
        clear_draw_hands_new_face_type
      end
      break if (1..2).include?(c)
    end
  end

  def ask_insurance
    puts ' Insurance?  (Y) Yes  (N) No'
    loop do
      c = Blackjack.getc
      case c
      when 'y'
        insure_hand
      when 'n'
        no_insurance
      else
        clear_draw_hands_ask_insurance
      end
      break if %w[y n].include?(c)
    end
  end

  def draw_bet_options
    puts ' (D) Deal Hand  (B) Change Bet  (O) Options  (Q) Quit'
    c = Blackjack.getc
    case c
    when 'd'
      deal_new_hand
    when 'b'
      new_bet
    when 'o'
      clear_draw_hands_game_options
    when 'q'
      clear
      exit
    else
      clear_draw_hands_bet_options
    end
  end
end
