# frozen_string_literal: true

require_relative 'blackjack/dealer_hand'
require_relative 'blackjack/format'
require_relative 'blackjack/menus'
require_relative 'blackjack/player_hand'
require_relative 'blackjack/shoe'
require_relative 'blackjack/split_hand'
require_relative 'blackjack/utils'

SAVE_FILE = 'bj.txt'
MIN_BET = 500
MAX_BET = 10_000_000

class Blackjack
  include Menus
  include SplitHand
  include Utils

  attr_accessor :shoe, :money, :player_hands, :dealer_hand, :num_decks,
                :deck_type, :face_type, :current_bet, :current_hand

  def initialize
    @num_decks = 1
    @face_type = 1
    @deck_type = 1
    @money = 10_000
    @current_bet = 500
  end

  def run
    load_game
    @shoe = Shoe.new(self, num_decks)
    deal_new_hand
  end

  def current_player_hand
    player_hands[current_hand]
  end

  def build_new_hand
    self.player_hands = []
    player_hand = PlayerHand.new(self, current_bet)
    player_hands << player_hand
    self.current_hand = 0

    self.dealer_hand = DealerHand.new(self)

    2.times do
      player_hand.deal_card
      dealer_hand.deal_card
    end
    player_hand
  end

  def deal_new_hand
    shoe.send("new_#{SHOES[deck_type]}") if shoe.needs_to_shuffle?
    player_hand = build_new_hand

    if dealer_hand.upcard_is_ace? && !player_hand.blackjack?
      draw_hands
      ask_insurance
    elsif player_hand.done?
      dealer_hand.hide_first_card = false
      pay_hands
      draw_hands
      draw_bet_options
    else
      draw_hands
      player_hand.action?
      save_game
    end
  end

  def more_hands_to_play?
    current_hand < player_hands.size - 1
  end

  def play_more_hands
    self.current_hand += 1
    current_player_hand.deal_card

    if current_player_hand.done?
      current_player_hand.process
    else
      draw_hands_current_hand_action
    end
  end

  def need_to_play_dealer_hand?
    player_hands.each do |player_hand|
      return true unless player_hand.busted? || player_hand.blackjack?
    end
    false
  end

  def pay_hands
    dealer_hand_value = dealer_hand.value(:soft)
    dealer_busted = dealer_hand.busted?

    player_hands.each do |player_hand|
      player_hand.pay(dealer_hand_value, dealer_busted)
    end

    normalize_current_bet
    save_game
  end

  def clear
    return if ENV['CLEAR_TERM'] == '0'

    system('export TERM=linux; clear')
  end

  def draw_hands
    clear
    out = String.new
    out << "\n Dealer:\n#{dealer_hand.draw}\n"
    out << "\n Player $"
    out << Format.money(money / 100.0)
    out << ":\n"
    out << draw_player_hands
    puts out
  end

  def draw_player_hands
    out = String.new('')
    player_hands.each_with_index do |player_hand, index|
      out << player_hand.draw(index)
    end
    out
  end

  def new_bet(input)
    clear
    draw_hands

    puts " Current Bet: $#{Format.money(current_bet / 100)}\n"
    print ' Enter New Bet: $'

    self.current_bet = input.gets.to_i * 100

    normalize_current_bet
    deal_new_hand
  end

  def new_num_decks(input)
    puts " Number Of Decks: #{num_decks}"
    print ' New Number Of Decks (1-8): '
    self.num_decks = input.gets.to_i

    normalize_num_decks
    clear_draw_hands_game_options
  end

  def normalize_num_decks
    self.num_decks = 1 if num_decks < 1
    self.num_decks = 8 if num_decks > 8
  end

  def insure_hand
    player_hand = current_player_hand
    player_hand.bet /= 2
    player_hand.played = true
    player_hand.paid = true
    player_hand.status = :lost

    self.money -= player_hand.bet

    draw_hands
    draw_bet_options
  end

  def no_insurance
    if dealer_hand.blackjack?
      dealer_hand.hide_first_card = false

      pay_hands
      draw_hands
      draw_bet_options
    else
      player_hand = current_player_hand

      if player_hand.done?
        play_dealer_hand
      else
        draw_hands
        player_hand.action?
      end
    end
  end

  def all_bets
    player_hands.inject(0) { |sum, player_hand| sum + player_hand.bet }
  end

  def normalize_current_bet
    if current_bet < MIN_BET
      self.current_bet = MIN_BET
    elsif current_bet > MAX_BET
      self.current_bet = MAX_BET
    end

    self.current_bet = money if current_bet > money
  end

  def self.getc(input)
    begin
      system('stty raw -echo')
      c = input.getc
    ensure
      system('stty -raw echo')
    end
    c.chr
  end
end
