# frozen_string_literal: true

RSpec.describe Blackjack do
  let(:blackjack) { build(:blackjack, shoe: build(:shoe, :new_regular)) }
  let(:player_hand) { build(:player_hand, blackjack:) }
  let(:dealer_hand) { build(:dealer_hand, blackjack:) }
  let(:ace) { build(:card, :ace, blackjack:) }
  let(:ten) { build(:card, :ten, blackjack:) }
  let(:input) { StringIO.new }

  describe '#current_player_hand' do
    it 'returns the current hand' do
      blackjack.player_hands << player_hand
      expect(blackjack.current_player_hand).to eq(player_hand)
    end
  end

  describe '#more_hands_to_play?' do
    it 'returns false' do
      expect(blackjack).to_not be_more_hands_to_play
    end

    it 'returns true' do
      blackjack.player_hands << player_hand << player_hand
      expect(blackjack).to be_more_hands_to_play
    end
  end

  describe '#getc' do
    it 'get a single character from stdin' do
      allow(input).to receive(:getc).and_return('q')
      c = described_class.getc(input)
      expect(c).to eq('q')
    end
  end

  describe '.all_bets?' do
    it 'returns 10' do
      blackjack.player_hands << player_hand << player_hand
      expect(blackjack.all_bets).to eq(1000)
    end
  end

  describe '#need_to_play_dealer_hand?' do
    before do
      blackjack.player_hands << player_hand
    end

    context 'when busted' do
      it 'returns false' do
        allow(player_hand).to receive(:blackjack?).and_return(false)
        allow(player_hand).to receive(:busted?).and_return(true)
        expect(blackjack).to_not be_need_to_play_dealer_hand
      end
    end

    context 'when blackjack' do
      it 'returns false' do
        allow(player_hand).to receive(:busted?).and_return(false)
        allow(player_hand).to receive(:blackjack?).and_return(true)
        expect(blackjack).to_not be_need_to_play_dealer_hand
      end
    end
  end

  describe '#normalize_current_bet' do
    it 'reduces the current bet to money' do
      blackjack.current_bet = blackjack.money + 1
      blackjack.normalize_current_bet
      expect(blackjack.current_bet).to eq(blackjack.money)
    end

    it 'reduces the current bet to MAX_BET' do
      blackjack.money = MAX_BET + 1
      blackjack.current_bet = MAX_BET + 1
      blackjack.normalize_current_bet
      expect(blackjack.current_bet).to eq(MAX_BET)
    end

    it 'increases the current bet to MIN_BET' do
      blackjack.current_bet = MIN_BET - 1
      blackjack.normalize_current_bet
      expect(blackjack.current_bet).to eq(MIN_BET)
    end
  end

  describe '#clear' do
    it 'calls system' do
      ENV['CLEAR_TERM'] = '1'
      allow(blackjack).to receive(:system)
      blackjack.clear
      expect(blackjack).to have_received(:system).with('export TERM=linux; clear')
    end

    it 'does not call system' do
      ENV['CLEAR_TERM'] = '0'
      allow(blackjack).to receive(:system)
      blackjack.clear
      expect(blackjack).to_not have_received(:system)
    end
  end

  describe '#save_game' do
    let(:file) { instance_double(File) }

    before do
      allow(File).to receive(:open).with(SAVE_FILE, 'w').and_yield(file)
      allow(file).to receive(:puts)
    end

    it 'opens and put save file data' do
      blackjack.save_game
      expected = %i[num_decks deck_type face_type money current_bet].map do |f|
        blackjack.send(f)
      end.join('|')
      expect(file).to have_received(:puts).with(expected)
    end
  end

  describe '#load_game' do
    context 'with a unreadable save file' do
      it 'fails to load save file' do
        allow(File).to receive(:read).with(SAVE_FILE)
        allow(File).to receive(:readable?).with(SAVE_FILE).and_return(false)

        blackjack.load_game
        expect(File).to_not have_received(:read).with(SAVE_FILE)
      end
    end

    context 'with a readabale save file' do
      before do
        allow(File).to receive(:readable?).with(SAVE_FILE).and_return(true)
        allow(File).to receive(:read).with(SAVE_FILE).and_return('8|1|1|2000|1000')
      end

      it 'loads num_decks from save file data' do
        blackjack.load_game
        expect(blackjack.num_decks).to eq(8)
      end

      it 'loads face_type from save file data' do
        blackjack.load_game
        expect(blackjack.face_type).to eq(1)
      end

      it 'loads money from save file data' do
        blackjack.load_game
        expect(blackjack.money).to eq(2000)
      end

      it 'loads current_bet from save file data' do
        blackjack.load_game
        expect(blackjack.current_bet).to eq(1000)
      end
    end
  end

  describe '#run' do
    before do
      allow(blackjack).to receive(:load_game)
      allow(blackjack).to receive(:deal_new_hand)
      allow(Shoe).to receive(:new)
    end

    it 'calls load_game' do
      blackjack.run
      expect(blackjack).to have_received(:load_game)
    end

    it 'creates a new shoe' do
      blackjack.run
      expect(Shoe).to have_received(:new)
    end

    it 'deals a new hand' do
      blackjack.run
      expect(blackjack).to have_received(:deal_new_hand)
    end
  end

  describe '#draw_bet_options' do
    before do
      allow(blackjack).to receive(:puts)
    end

    context 'when dealing a new hand' do
      it 'deals a new hand' do
        allow(described_class).to receive(:getc).and_return('d')
        allow(blackjack).to receive(:deal_new_hand)
        blackjack.draw_bet_options
        expect(blackjack).to have_received(:deal_new_hand)
      end
    end

    context 'when updating current bet' do
      it 'deals a new hand' do
        allow(described_class).to receive(:getc).and_return('b')
        allow(blackjack).to receive(:new_bet)
        blackjack.draw_bet_options
        expect(blackjack).to have_received(:new_bet)
      end
    end

    context 'when updating blackjack options' do
      before do
        blackjack.dealer_hand = dealer_hand
        allow(described_class).to receive(:getc).and_return('o')
      end

      it 'draws blackjack options' do
        allow(blackjack).to receive(:draw_game_options)
        blackjack.draw_bet_options
        expect(blackjack).to have_received(:draw_game_options)
      end

      it 'draws hands' do
        allow(blackjack).to receive(:draw_game_options)
        allow(blackjack).to receive(:draw_hands)
        blackjack.draw_bet_options
        expect(blackjack).to have_received(:draw_hands)
      end

      it 'clears the screen' do
        allow(blackjack).to receive(:draw_game_options)
        allow(blackjack).to receive(:draw_hands)
        allow(blackjack).to receive(:clear)
        blackjack.draw_bet_options
        expect(blackjack).to have_received(:clear)
      end
    end

    context 'when quitting' do
      it 'clears the screen and exits' do
        allow(described_class).to receive(:getc).and_return('q')
        allow(blackjack).to receive(:clear)
        expect { blackjack.draw_bet_options }.to raise_error(SystemExit)
        expect(blackjack).to have_received(:clear)
      end
    end

    context 'when invalid input' do
      it 'gets the action again' do
        blackjack.dealer_hand = dealer_hand
        allow(described_class).to receive(:getc).and_return('x', 'q')
        expect { blackjack.draw_bet_options }.to raise_error(SystemExit)
      end
    end
  end

  describe '#build_new_hand' do
    before do
      blackjack.build_new_hand
    end

    it 'creates a player hand' do
      expect(blackjack.player_hands.size).to eq(1)
    end

    it 'sets current hand to zero' do
      expect(blackjack.current_hand).to be_zero
    end

    it 'creates a dealerhand' do
      expect(blackjack.dealer_hand).to be
    end

    it 'player hand has two cards' do
      expect(blackjack.player_hands.first.cards.size).to eq(2)
    end

    it 'dealer hand has two cards' do
      expect(blackjack.dealer_hand.cards.size).to eq(2)
    end
  end

  describe '#deal_new_hand' do
    before do
      blackjack.player_hands << player_hand
      blackjack.dealer_hand = dealer_hand
      allow(blackjack).to receive(:draw_hands)
    end

    context 'when shuffling may be required' do
      before do
        dealer_hand.cards << ten << ten
        allow(blackjack).to receive(:build_new_hand).and_return(player_hand)
        allow(player_hand).to receive(:action?)
        allow(blackjack.shoe).to receive(:new_regular)
      end

      it 'shuffles' do
        allow(blackjack.shoe).to receive(:needs_to_shuffle?).and_return(true)
        blackjack.deal_new_hand
        expect(blackjack.shoe).to have_received(:new_regular)
      end

      it 'does not shuffle' do
        allow(blackjack.shoe).to receive(:needs_to_shuffle?).and_return(false)
        blackjack.deal_new_hand
        expect(blackjack.shoe).to_not have_received(:new_regular)
      end
    end

    context 'when the dealer upcard is ace and player hand is not busted' do
      before do
        allow(blackjack).to receive(:build_new_hand).and_return(player_hand)
        dealer_hand.cards << ace << ten
      end

      it 'asks about insurance' do
        allow(blackjack).to receive(:ask_insurance)
        blackjack.deal_new_hand
        expect(blackjack).to have_received(:ask_insurance)
      end
    end

    context 'when the player hand is done' do
      before do
        allow(blackjack).to receive(:build_new_hand).and_return(player_hand)
        allow(player_hand).to receive(:action?)
        allow(dealer_hand).to receive(:upcard_is_ace?).and_return(false)
        allow(blackjack).to receive(:draw_bet_options)
        allow(player_hand).to receive(:done?).and_return(true)
      end

      it 'shows dealer down card' do
        blackjack.deal_new_hand
        expect(dealer_hand.hide_down_card).to be_falsey
      end

      it 'hands are paid' do
        allow(blackjack).to receive(:pay_hands)
        blackjack.deal_new_hand
        expect(blackjack).to have_received(:pay_hands)
      end

      it 'hands are drawn' do
        blackjack.deal_new_hand
        expect(blackjack).to have_received(:draw_hands)
      end

      it 'bet options are drawn' do
        blackjack.deal_new_hand
        expect(blackjack).to have_received(:draw_bet_options)
      end
    end
  end

  describe '#play_more_hands' do
    before do
      blackjack.player_hands << player_hand
      allow(blackjack).to receive(:current_player_hand).and_return(player_hand)
    end

    context 'when current hand is done' do
      it 'processes current player hand' do
        allow(player_hand).to receive(:done?).and_return(true)
        allow(player_hand).to receive(:process)
        blackjack.play_more_hands
        expect(player_hand).to have_received(:process)
      end
    end

    context 'when current hand is not done' do
      before do
        allow(player_hand).to receive(:done?).and_return(false)
        allow(blackjack).to receive(:draw_hands)
        allow(blackjack).to receive(:draw_bet_options)
        allow(player_hand).to receive(:action?)
        blackjack.dealer_hand = dealer_hand
        blackjack.play_more_hands
      end

      it 'draws hands' do
        expect(blackjack).to have_received(:draw_hands)
      end

      it 'gets current player hand action' do
        expect(player_hand).to have_received(:action?)
      end
    end
  end

  describe '#draw_hands' do
    before do
      player_hand.cards << ace << ten
      blackjack.player_hands << player_hand
      dealer_hand.cards << ten << ten
      blackjack.dealer_hand = dealer_hand
      allow(blackjack).to receive(:puts)
    end

    it 'draws the hands' do
      blackjack.draw_hands
      expected = "\n Dealer:\n 🂪 🂠  ⇒  10\n\n Player $100.00:\n 🂡 🂪  ⇒  21  $5.00 ⇐  \n\n"
      expect(blackjack).to have_received(:puts).with(expected)
    end
  end

  describe '#new_bet' do
    before do
      blackjack.dealer_hand = dealer_hand
      allow(input).to receive(:gets).and_return('10')
      allow(described_class).to receive(:getc).and_return('s', 'q')
      allow(blackjack).to receive(:print)
      allow(blackjack).to receive(:puts)
      allow(blackjack).to receive(:deal_new_hand)
      allow(blackjack).to receive(:clear)
      allow(blackjack).to receive(:draw_hands)
      allow(blackjack).to receive(:normalize_current_bet)
    end

    it 'clears the screen' do
      blackjack.new_bet(input)
      expect(blackjack).to have_received(:clear)
    end

    it 'draws hands' do
      blackjack.new_bet(input)
      expect(blackjack).to have_received(:draw_hands)
    end

    it 'draws the current bet' do
      blackjack.new_bet(input)
      expected = " Current Bet: $5.00\n"
      expect(blackjack).to have_received(:puts).with(expected)
    end

    it 'updates current bet' do
      blackjack.new_bet(input)
      expect(blackjack.current_bet).to eq(1000)
    end

    it 'normalizes the bet' do
      blackjack.new_bet(input)
      expect(blackjack).to have_received(:normalize_current_bet)
    end

    it 'deals a new hand' do
      blackjack.new_bet(input)
      expect(blackjack).to have_received(:deal_new_hand)
    end
  end

  describe '#draw_game_options' do
    before do
      blackjack.dealer_hand = dealer_hand
    end

    context 'when updating number of decks' do
      before do
        allow(described_class).to receive(:getc).and_return('n')
        allow(blackjack).to receive(:clear)
        allow(blackjack).to receive(:draw_hands)
        allow(blackjack).to receive(:new_num_decks)
        allow(blackjack).to receive(:puts)
      end

      it 'draws the blackjack options' do
        blackjack.draw_game_options
        expected = ' (N) Number of Decks  (T) Deck Type  (F) Face Type  (B) Back'
        expect(blackjack).to have_received(:puts).with(expected)
      end

      it 'clears the screen' do
        blackjack.draw_game_options
        expect(blackjack).to have_received(:clear)
      end

      it 'draws the hands' do
        blackjack.draw_game_options
        expect(blackjack).to have_received(:draw_hands)
      end

      it 'updates number of decks' do
        blackjack.draw_game_options
        expect(blackjack).to have_received(:new_num_decks)
      end
    end

    context 'when updating the deck type' do
      before do
        allow(described_class).to receive(:getc).and_return('t')
        allow(blackjack).to receive(:clear)
        allow(blackjack).to receive(:draw_hands)
        allow(blackjack).to receive(:new_deck_type)
        allow(blackjack).to receive(:draw_bet_options)
        allow(blackjack).to receive(:puts)
      end

      it 'clears the screen' do
        blackjack.draw_game_options
        expect(blackjack).to have_received(:clear).twice
      end

      it 'draws the hands' do
        blackjack.draw_game_options
        expect(blackjack).to have_received(:draw_hands).twice
      end

      it 'updates deck type' do
        blackjack.draw_game_options
        expect(blackjack).to have_received(:new_deck_type)
      end

      it 'draws the bet options' do
        blackjack.draw_game_options
        expect(blackjack).to have_received(:draw_bet_options)
      end
    end

    context 'when updating the face type' do
      before do
        allow(described_class).to receive(:getc).and_return('f')
        allow(blackjack).to receive(:clear)
        allow(blackjack).to receive(:draw_hands)
        allow(blackjack).to receive(:new_face_type)
        allow(blackjack).to receive(:draw_bet_options)
        allow(blackjack).to receive(:puts)
      end

      it 'clears the screen' do
        blackjack.draw_game_options
        expect(blackjack).to have_received(:clear).twice
      end

      it 'draws the hands' do
        blackjack.draw_game_options
        expect(blackjack).to have_received(:draw_hands).twice
      end

      it 'updates face type' do
        blackjack.draw_game_options
        expect(blackjack).to have_received(:new_face_type)
      end

      it 'draws the bet options' do
        blackjack.draw_game_options
        expect(blackjack).to have_received(:draw_bet_options)
      end
    end

    context 'when going back to previous menu' do
      before do
        allow(described_class).to receive(:getc).and_return('b')
        allow(blackjack).to receive(:clear)
        allow(blackjack).to receive(:draw_hands)
        allow(blackjack).to receive(:draw_bet_options)
        allow(blackjack).to receive(:puts)
      end

      it 'clears the screen' do
        blackjack.draw_game_options
        expect(blackjack).to have_received(:clear)
      end

      it 'draws the hands' do
        blackjack.draw_game_options
        expect(blackjack).to have_received(:draw_hands)
      end

      it 'draws the bet options' do
        blackjack.draw_game_options
        expect(blackjack).to have_received(:draw_bet_options)
      end
    end

    context 'when invalid input' do
      before do
        allow(described_class).to receive(:getc).and_return('x', 'b')
        allow(blackjack).to receive(:puts)
        allow(blackjack).to receive(:new_bet)
        allow(blackjack).to receive(:draw_bet_options)
        allow(blackjack).to receive(:draw_hands)
      end

      it 'gets the action again' do
        blackjack.draw_game_options
        allow(blackjack).to receive(:draw_game_options)
        expect(blackjack).to have_received(:draw_bet_options).twice
      end
    end
  end

  describe '#new_num_decks' do
    before do
      blackjack.dealer_hand = dealer_hand
      allow(input).to receive(:gets).and_return('2')
      allow(described_class).to receive(:getc).and_return('b', 'q')
      allow(blackjack).to receive(:print)
      allow(blackjack).to receive(:puts)
      allow(blackjack).to receive(:clear)
      allow(blackjack).to receive(:draw_hands)
      allow(blackjack).to receive(:draw_game_options)
      allow(blackjack).to receive(:normalize_num_decks)
    end

    it 'clears screen' do
      blackjack.new_num_decks(input)
      expect(blackjack).to have_received(:clear)
    end

    it 'draws hands' do
      blackjack.new_num_decks(input)
      expect(blackjack).to have_received(:draw_hands)
    end

    it 'gets new number of decks' do
      blackjack.new_num_decks(input)
      expect(blackjack.num_decks).to eq(2)
    end

    it 'normalizes number of decks' do
      blackjack.new_num_decks(input)
      expect(blackjack).to have_received(:normalize_num_decks)
    end
  end

  describe '#normalize_num_decks' do
    it 'increases the value' do
      blackjack.num_decks = 0
      blackjack.normalize_num_decks
      expect(blackjack.num_decks).to eq(1)
    end

    it 'decreases the value' do
      blackjack.num_decks = 9
      blackjack.normalize_num_decks
      expect(blackjack.num_decks).to eq(8)
    end

    it 'leaves the value unaltered' do
      blackjack.num_decks = 2
      blackjack.normalize_num_decks
      expect(blackjack.num_decks).to eq(2)
    end
  end

  describe '#new_deck_type' do
    before do
      blackjack.dealer_hand = dealer_hand
      allow(blackjack).to receive(:puts)
      allow(blackjack).to receive(:save_game)
    end

    context 'when choosing a new deck type' do
      it 'draws options' do
        allow(described_class).to receive(:getc).and_return('1')
        blackjack.new_deck_type
        expected = ' (1) Regular  (2) Aces  (3) Jacks  (4) Aces & Jacks  (5) Sevens  (6) Eights'
        expect(blackjack).to have_received(:puts).with(expected)
      end

      it 'builds a new regular' do
        allow(described_class).to receive(:getc).and_return('1')
        allow(blackjack.shoe).to receive(:new_regular)
        blackjack.new_deck_type
        expect(blackjack.shoe).to have_received(:new_regular)
        expect(blackjack).to have_received(:save_game)
      end

      it 'builds a new aces' do
        allow(described_class).to receive(:getc).and_return('2')
        allow(blackjack.shoe).to receive(:new_aces)
        blackjack.new_deck_type
        expect(blackjack.shoe).to have_received(:new_aces)
        expect(blackjack).to have_received(:save_game)
      end

      it 'builds a new jacks' do
        allow(described_class).to receive(:getc).and_return('3')
        allow(blackjack.shoe).to receive(:new_jacks)
        blackjack.new_deck_type
        expect(blackjack.shoe).to have_received(:new_jacks)
        expect(blackjack).to have_received(:save_game)
      end

      it 'builds a new aces_jacks' do
        allow(described_class).to receive(:getc).and_return('4')
        allow(blackjack.shoe).to receive(:new_aces_jacks)
        blackjack.new_deck_type
        expect(blackjack.shoe).to have_received(:new_aces_jacks)
        expect(blackjack).to have_received(:save_game)
      end

      it 'builds a new sevens' do
        allow(described_class).to receive(:getc).and_return('5')
        allow(blackjack.shoe).to receive(:new_sevens)
        blackjack.new_deck_type
        expect(blackjack.shoe).to have_received(:new_sevens)
        expect(blackjack).to have_received(:save_game)
      end

      it 'builds a new eights' do
        allow(described_class).to receive(:getc).and_return('6')
        allow(blackjack.shoe).to receive(:new_eights)
        blackjack.new_deck_type
        expect(blackjack.shoe).to have_received(:new_eights)
        expect(blackjack).to have_received(:save_game)
      end
    end

    context 'when invalid input' do
      it 'gets the action again' do
        allow(described_class).to receive(:getc).and_return('x', '1')
        allow(blackjack).to receive(:draw_hands)
        blackjack.new_deck_type
        expect(blackjack).to have_received(:draw_hands)
        expect(blackjack).to have_received(:save_game).twice
      end
    end
  end

  describe '#new_face_type' do
    before do
      blackjack.dealer_hand = dealer_hand
      allow(blackjack).to receive(:puts)
    end

    context 'when choosing a new face type' do
      it 'draws options' do
        allow(described_class).to receive(:getc).and_return('1')
        blackjack.new_face_type
        expected = ' (1) 🂡  (2) A♠'
        expect(blackjack).to have_received(:puts).with(expected)
      end

      it 'sets regular faces' do
        allow(described_class).to receive(:getc).and_return('1')
        allow(blackjack).to receive(:save_game)
        allow(blackjack).to receive(:face_type=).with(1)
        blackjack.new_face_type
        expect(blackjack).to have_received(:face_type=).with(1)
        expect(blackjack).to have_received(:save_game)
      end

      it 'sets alternate faces' do
        allow(described_class).to receive(:getc).and_return('2')
        allow(blackjack).to receive(:save_game)
        allow(blackjack).to receive(:face_type=).with(2)
        blackjack.new_face_type
        expect(blackjack).to have_received(:face_type=).with(2)
        expect(blackjack).to have_received(:save_game)
      end
    end

    context 'when invalid input' do
      it 'gets the action again' do
        allow(described_class).to receive(:getc).and_return('x', '1')
        allow(blackjack).to receive(:draw_hands)
        blackjack.new_face_type
        expect(blackjack).to have_received(:draw_hands)
      end
    end
  end

  describe '#ask_insurance' do
    before do
      allow(blackjack).to receive(:puts)
      allow(blackjack).to receive(:insure_hand)
      allow(blackjack).to receive(:no_insurance)
    end

    context 'when choosing to take insurance' do
      it 'draws options' do
        allow(described_class).to receive(:getc).and_return('y')
        blackjack.ask_insurance
        expected = ' Insurance?  (Y) Yes  (N) No'
        expect(blackjack).to have_received(:puts).with(expected)
      end

      it 'insures hand' do
        allow(described_class).to receive(:getc).and_return('y')
        blackjack.ask_insurance
        expect(blackjack).to have_received(:insure_hand)
      end

      it 'does not insure hand' do
        allow(described_class).to receive(:getc).and_return('n')
        blackjack.ask_insurance
        expect(blackjack).to have_received(:no_insurance)
      end
    end

    context 'when invalid input' do
      it 'asks again' do
        allow(described_class).to receive(:getc).and_return('x', 'y')
        allow(blackjack).to receive(:draw_hands)
        blackjack.ask_insurance
        expect(blackjack).to have_received(:draw_hands)
      end
    end
  end

  describe '#insure_hand' do
    before do
      blackjack.dealer_hand = dealer_hand
      blackjack.player_hands << player_hand
      allow(blackjack).to receive(:draw_hands)
      allow(blackjack).to receive(:draw_bet_options)
    end

    it 'reduces hand bet' do
      blackjack.insure_hand
      expect(player_hand.bet).to eq(250)
    end

    it 'sets hand as played' do
      blackjack.insure_hand
      expect(player_hand.played).to be_truthy
    end

    it 'sets hand as payed' do
      blackjack.insure_hand
      expect(player_hand.payed).to be_truthy
    end

    it 'sets hand status as LOST' do
      blackjack.insure_hand
      expect(player_hand.status).to eq(LOST)
    end

    it 'updates blackjack money' do
      blackjack.insure_hand
      expect(blackjack.money).to eq(9750)
    end

    it 'draws hands' do
      blackjack.insure_hand
      expect(blackjack).to have_received(:draw_hands)
    end

    it 'draws bet options' do
      blackjack.insure_hand
      expect(blackjack).to have_received(:draw_bet_options)
    end
  end

  describe '#no_insurance' do
    before do
      blackjack.dealer_hand = dealer_hand
      blackjack.player_hands << player_hand
      allow(player_hand).to receive(:action?)
      allow(blackjack).to receive(:draw_bet_options)
      allow(blackjack).to receive(:draw_hands)
      allow(blackjack).to receive(:pay_hands)
    end

    context 'when dealer hand is blackjack' do
      before do
        dealer_hand.cards << ace << ten
      end

      it 'shows dealer down card' do
        blackjack.no_insurance
        expect(dealer_hand.hide_down_card).to be_falsey
      end

      it 'pays hands' do
        blackjack.no_insurance
        expect(blackjack).to have_received(:pay_hands)
      end

      it 'draws hands' do
        blackjack.no_insurance
        expect(blackjack).to have_received(:draw_hands)
      end

      it 'draws bet options' do
        blackjack.no_insurance
        expect(blackjack).to have_received(:draw_bet_options)
      end
    end

    context 'when dealer hand is not blackjack' do
      before do
        dealer_hand.cards << ace << build(:card, :seven)
        allow(blackjack).to receive(:play_dealer_hand)
      end

      it 'plays dealer hand' do
        allow(player_hand).to receive(:done?).and_return(true)
        blackjack.no_insurance
        expect(blackjack).to have_received(:play_dealer_hand)
      end

      it 'draws hands' do
        allow(player_hand).to receive(:done?).and_return(false)
        blackjack.no_insurance
        expect(blackjack).to have_received(:draw_hands)
      end

      it 'gets player hand action' do
        allow(player_hand).to receive(:done?).and_return(false)
        blackjack.no_insurance
        expect(player_hand).to have_received(:action?)
      end
    end
  end

  describe '#play_dealer_hand' do
    before do
      blackjack.dealer_hand = dealer_hand
      allow(dealer_hand).to receive(:play)
      allow(blackjack).to receive(:draw_bet_options)
      allow(blackjack).to receive(:draw_hands)
    end

    it 'plays dealer hand' do
      blackjack.play_dealer_hand
      expect(dealer_hand).to have_received(:play)
    end

    it 'draws bet options' do
      blackjack.play_dealer_hand
      expect(blackjack).to have_received(:draw_bet_options)
    end

    it 'draws hands' do
      blackjack.play_dealer_hand
      expect(blackjack).to have_received(:draw_hands)
    end
  end

  describe '#split_current_hand' do
    before do
      blackjack.dealer_hand = dealer_hand
      blackjack.player_hands << player_hand
      allow(blackjack).to receive(:current_player_hand).and_return(player_hand)
    end

    context 'when current hand can split' do
      before do
        player_hand.cards << build(:card, :six) << build(:card, :six)
        allow(described_class).to receive(:getc).and_return('s', 's')
        allow(blackjack).to receive(:draw_bet_options)
        allow(blackjack).to receive(:draw_hands)
        allow(player_hand).to receive(:action?)
      end

      it 'splits hand' do
        blackjack.split_current_hand
        expect(blackjack.player_hands.size).to eq(2)
      end

      it 'first hand is done' do
        allow(player_hand).to receive(:done?).and_return(true)
        blackjack.split_current_hand
        expect(player_hand).to have_received(:done?).twice
      end
    end

    context 'when current hand cannot split' do
      before do
        player_hand.cards << ace << build(:card, :six)
        allow(described_class).to receive(:getc).and_return('s')
        allow(blackjack).to receive(:draw_bet_options)
        allow(blackjack).to receive(:draw_hands)
        allow(player_hand).to receive(:action?)
      end

      it 'draws hands' do
        blackjack.split_current_hand
        expect(blackjack).to have_received(:draw_hands)
      end

      it 'gets player hand action' do
        blackjack.split_current_hand
        expect(player_hand).to have_received(:action?)
      end
    end
  end
end
