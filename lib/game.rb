# frozen_string_literal: true

require_relative 'shoe'
require_relative 'dealer_hand'
require_relative 'player_hand'

SAVE_FILE = 'bj.txt'
MIN_BET = 500
MAX_BET = 10_000_000

class Game
  attr_accessor :shoe, :money, :player_hands, :dealer_hand, :num_decks, :current_bet, :current_hand

  def initialize
    @num_decks = 1
    @money = 10_000
    @current_bet = 500
  end

  def run
    load_game
    @shoe = Shoe.new(num_decks)
    deal_new_hand
  end

  def current_player_hand
    player_hands[current_hand]
  end

  def deal_new_hand
    shoe.new_regular if shoe.needs_to_shuffle?
    build_new_hand

    if dealer_hand.upcard_is_ace? && !player_hand.blackjack?
      draw_hands
      ask_insurance
    elsif player_hand.done?
      dealer_hand.hide_down_card = false
      pay_hands
      draw_hands
      draw_bet_options
    else
      draw_hands
      player_hand.action?
      save_game
    end
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
  end

  def more_hands_to_play?
    current_hand < player_hands.size - 1
  end

  def play_more_hands
    self.current_hand += 1

    current_player_hand.deal_card
    if current_player_hand.done?
      current_player_hand.process
      return
    end

    draw_hands
    current_player_hand.action?
  end

  def need_to_play_dealer_hand?
    player_hands.each do |player_hand|
      return true unless player_hand.busted? || player_hand.blackjack?
    end
    false
  end

  def normalize_current_bet
    if current_bet < MIN_BET
      self.current_bet = MIN_BET
    elsif current_bet > MAX_BET
      self.current_bet = MAX_BET
    end

    self.current_bet = money if current_bet > money
  end

  def pay_hands
    dhv = dealer_hand.value(SOFT)
    dhb = dealer_hand.busted?

    player_hands.each do |player_hand|
      next if player_hand.payed

      player_hand.payed = true
      phv = player_hand.value(SOFT)
      if dhb || phv > dhv
        player_hand.bet *= 1.5 if player_hand.blackjack?
        self.money += player_hand.bet
        player_hand.status = WON
      elsif phv < dhv
        self.money -= player_hand.bet
        player_hand.status = LOST
      else
        player_hand.status = PUSH
      end
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
    out << Game.format_money(money / 100.0)
    out << ":\n"

    player_hands.each_with_index do |player_hand, index|
      out << player_hand.draw(index)
    end

    puts out
  end

  def new_bet
    clear
    draw_hands

    puts " Current Bet: $#{Game.format_money(current_bet / 100)}\n"
    print ' Enter New Bet: $'

    tmp = STDIN.gets.to_i
    self.current_bet = tmp * 100

    normalize_current_bet
    deal_new_hand
  end

  def draw_game_options
    puts ' (N) Number of Decks  (T) Deck Type  (B) Back'

    loop do
      br = false
      case Game.getc
      when 'n'
        br = true
        clear
        draw_hands
        new_num_decks
      when 't'
        br = true
        clear
        draw_hands
        new_deck_type
        clear
        draw_hands
        draw_bet_options
      when 'b'
        br = true
        clear
        draw_hands
        draw_bet_options
      else
        clear
        draw_hands
        draw_game_options
      end

      break if br
    end
  end

  def new_num_decks
    puts " Number Of Decks: #{num_decks}"
    print ' New Number Of Decks (1-8): '
    tmp = STDIN.gets.to_i

    tmp = 1 if tmp < 1
    tmp = 8 if tmp > 8
    self.num_decks = tmp

    clear
    draw_hands
    draw_game_options
  end

  def new_deck_type
    puts ' (1) Regular  (2) Aces  (3) Jacks  (4) Aces & Jacks  (5) Sevens  (6) Eights'

    loop do
      br = false
      case Game.getc
      when '1'
        br = true
        shoe.new_regular
      when '2'
        br = true
        shoe.new_aces
      when '3'
        br = true
        shoe.new_jacks
      when '4'
        br = true
        shoe.new_aces_jacks
      when '5'
        br = true
        shoe.new_sevens
      when '6'
        br = true
        shoe.new_eights
      else
        clear
        draw_hands
        new_deck_type
      end

      break if br
    end
  end

  def ask_insurance
    puts ' Insurance?  (Y) Yes  (N) No'

    loop do
      br = false
      case Game.getc
      when 'y'
        br = true
        insure_hand
      when 'n'
        br = true
        no_insurance
      else
        clear
        draw_hands
        ask_insurance
      end

      break if br
    end
  end

  def insure_hand
    player_hand = current_player_hand
    player_hand.bet /= 2
    player_hand.played = true
    player_hand.payed = true
    player_hand.status = LOST

    self.money -= player_hand.bet

    draw_hands
    draw_bet_options
  end

  def no_insurance
    if dealer_hand.blackjack?
      dealer_hand.hide_down_card = false
      dealer_hand.played = true

      pay_hands
      draw_hands
      draw_bet_options
      return
    end

    player_hand = current_player_hand
    if player_hand.done?
      play_dealer_hand
      return
    end

    draw_hands
    player_hand.action?
  end

  def play_dealer_hand
    dealer_hand.play
    draw_hands
    draw_bet_options
  end

  def split_current_hand
    unless current_player_hand.can_split?
      draw_hands
      current_player_hand.action?
      return
    end

    player_hands << PlayerHand.new(self, current_bet)

    x = player_hands.size - 1
    while x > current_hand
      player_hands[x] = player_hands[x - 1].clone
      x -= 1
    end

    this_hand = player_hands[current_hand]
    split_hand = player_hands[current_hand + 1]

    split_hand.cards = []
    split_hand.cards << this_hand.cards.last
    this_hand.cards.pop

    this_hand.cards << shoe.next_card
    if this_hand.done?
      this_hand.process
      return
    end

    draw_hands
    current_player_hand.action?
  end

  def draw_bet_options
    puts ' (D) Deal Hand  (B) Change Bet  (O) Options  (Q) Quit'

    loop do
      br = false
      case Game.getc
      when 'd'
        br = true
        deal_new_hand
      when 'b'
        br = true
        new_bet
      when 'o'
        br = true
        clear
        draw_hands
        draw_game_options
      when 'q'
        clear
        exit
      else
        clear
        draw_hands
        draw_bet_options
      end

      break if br
    end
  end

  def all_bets
    player_hands.inject(0) { |sum, player_hand| sum + player_hand.bet }
  end

  def save_game
    File.open(SAVE_FILE, 'w') do |file|
      file.puts "#{num_decks}|#{money}|#{current_bet}"
    end
  end

  def load_game
    return unless File.readable?(SAVE_FILE)

    a = File.read(SAVE_FILE).split('|')
    self.num_decks = a[0].to_i
    self.money = a[1].to_i
    self.current_bet = a[2].to_i
  end

  def self.getc
    begin
      system('stty raw -echo')
      c = STDIN.getc
    ensure
      system('stty -raw echo')
    end
    c.chr
  end

  def self.format_money(value)
    format('%.2f', value)
  end
end
