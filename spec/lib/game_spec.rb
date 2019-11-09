# frozen_string_literal: true

RSpec.describe Game do
  let(:shoe) { build(:shoe, :new_regular) }
  let(:game) { build(:game, shoe: shoe) }
  let(:player_hand) { build(:player_hand, game: game) }
  let(:dealer_hand) { build(:dealer_hand, game: game) }
  let(:ace) { build(:card, :ace) }
  let(:seven) { build(:card, :seven) }
  let(:six) { build(:card, :six) }
  let(:ten) { build(:card, :ten) }

  describe '#current_player_hand' do
    it 'returns the current hand' do
      game.player_hands << player_hand
      expect(game.current_player_hand).to eq(player_hand)
    end
  end

  describe '#more_hands_to_play?' do
    it 'returns false' do
      expect(game).to_not be_more_hands_to_play
    end

    it 'returns true' do
      game.player_hands << player_hand << player_hand
      expect(game).to be_more_hands_to_play
    end
  end

  describe '#getc' do
    it 'get a single character from stdin' do
      allow(STDIN).to receive(:getc).and_return('q')
      c = described_class.getc
      expect(c).to eq('q')
    end
  end

  describe '#format_money' do
    it 'returns a formatted string' do
      str = described_class.format_money(1)
      expect(str).to eq('1.00')
    end
  end

  describe '.all_bets?' do
    it 'returns 10' do
      game.player_hands << player_hand << player_hand
      expect(game.all_bets).to eq(1000)
    end
  end

  describe '#need_to_play_dealer_hand?' do
    it 'returns false' do
      expect(game).to_not be_need_to_play_dealer_hand
    end

    it 'returns true' do
      game.player_hands << player_hand
      expect(game).to be_need_to_play_dealer_hand
    end
  end

  describe '#normalize_current_bet' do
    it 'reduces the current bet to money' do
      game.current_bet = game.money + 1
      game.normalize_current_bet
      expect(game.current_bet).to eq(game.money)
    end

    it 'reduces the current bet to MAX_BET' do
      game.money = MAX_BET + 1
      game.current_bet = MAX_BET + 1
      game.normalize_current_bet
      expect(game.current_bet).to eq(MAX_BET)
    end

    it 'increases the current bet to MIN_BET' do
      game.current_bet = MIN_BET - 1
      game.normalize_current_bet
      expect(game.current_bet).to eq(MIN_BET)
    end
  end

  describe '#clear' do
    it 'calls system' do
      ENV['CLEAR_TERM'] = '1'
      allow(game).to receive(:system)
      game.clear
      expect(game).to have_received(:system).with('export TERM=linux; clear')
    end

    it 'does not call system' do
      ENV['CLEAR_TERM'] = '0'
      allow(game).to receive(:system)
      game.clear
      expect(game).to_not have_received(:system)
    end
  end

  describe '#save_game' do
    let(:file) { instance_double('File') }
    let(:content) { "#{game.num_decks}|#{game.money}|#{game.current_bet}" }

    it 'opens and put save file data' do
      allow(File).to receive(:open).with(SAVE_FILE, 'w').and_yield(file)
      allow(file).to receive(:puts)
      game.save_game
      expect(file).to have_received(:puts).with(content)
    end
  end

  describe '#load_game' do
    let(:content) { '8|2000|1000' }

    before do
      allow(File).to receive(:readable?).with(SAVE_FILE).and_return(true)
      allow(File).to receive(:read).with(SAVE_FILE).and_return(content)
    end

    it 'loads num_decks from save file data' do
      game.load_game
      expect(game.num_decks).to eq(8)
    end

    it 'loads money from save file data' do
      game.load_game
      expect(game.money).to eq(2000)
    end

    it 'loads current_bet from save file data' do
      game.load_game
      expect(game.current_bet).to eq(1000)
    end
  end

  describe '#run' do
    before do
      allow(game).to receive(:load_game)
      allow(game).to receive(:deal_new_hand)
      allow(Shoe).to receive(:new)
    end

    it 'calls load_game' do
      game.run
      expect(game).to have_received(:load_game)
    end

    it 'creates a new shoe' do
      game.run
      expect(Shoe).to have_received(:new)
    end

    it 'deals a new hand' do
      game.run
      expect(game).to have_received(:deal_new_hand)
    end
  end

  describe '#draw_bet_options' do
    before do
      allow(game).to receive(:puts)
    end

    context 'when dealing a new hand' do
      it 'deals a new hand' do
        allow(described_class).to receive(:getc).and_return('d')
        allow(game).to receive(:deal_new_hand)
        game.draw_bet_options
        expect(game).to have_received(:deal_new_hand)
      end
    end

    context 'when updating current bet' do
      it 'deals a new hand' do
        allow(described_class).to receive(:getc).and_return('b')
        allow(game).to receive(:new_bet)
        game.draw_bet_options
        expect(game).to have_received(:new_bet)
      end
    end

    context 'when updating game options' do
      before do
        game.dealer_hand = dealer_hand
        allow(described_class).to receive(:getc).and_return('o')
      end

      it 'draws game options' do
        allow(game).to receive(:draw_game_options)
        game.draw_bet_options
        expect(game).to have_received(:draw_game_options)
      end

      it 'draws hands' do
        allow(game).to receive(:draw_game_options)
        allow(game).to receive(:draw_hands)
        game.draw_bet_options
        expect(game).to have_received(:draw_hands)
      end

      it 'clears the screen' do
        allow(game).to receive(:draw_game_options)
        allow(game).to receive(:draw_hands)
        allow(game).to receive(:clear)
        game.draw_bet_options
        expect(game).to have_received(:clear)
      end
    end

    context 'when quitting' do
      it 'clears the screen and exits' do
        allow(described_class).to receive(:getc).and_return('q')
        allow(game).to receive(:clear)
        expect { game.draw_bet_options }.to raise_error(SystemExit)
        expect(game).to have_received(:clear)
      end
    end

    context 'when invalid input' do
      it 'gets the action again' do
        game.dealer_hand = dealer_hand
        allow(described_class).to receive(:getc).and_return('x', 'q') # ?, quit
        expect { game.draw_bet_options }.to raise_error(SystemExit)
      end
    end
  end

  describe '#build_new_hand' do
    before do
      game.build_new_hand
    end

    it 'creates a player hand' do
      expect(game.player_hands.size).to eq(1)
    end

    it 'sets current hand to zero' do
      expect(game.current_hand).to be_zero
    end

    it 'creates a dealerhand' do
      expect(game.dealer_hand).to be
    end

    it 'player hand has two cards' do
      expect(game.player_hands.first.cards.size).to eq(2)
    end

    it 'dealer hand has two cards' do
      expect(game.dealer_hand.cards.size).to eq(2)
    end
  end

  describe '#deal_new_hand' do
    before do
      game.player_hands << player_hand
      game.dealer_hand = dealer_hand
      allow(game).to receive(:draw_hands)
    end

    context 'when shuffling may be required' do
      before do
        dealer_hand.cards << ten << ten
        allow(game).to receive(:build_new_hand).and_return(player_hand)
        allow(player_hand).to receive(:action?)
        allow(shoe).to receive(:new_regular)
      end

      it 'shuffles' do
        allow(shoe).to receive(:needs_to_shuffle?).and_return(true)
        game.deal_new_hand
        expect(shoe).to have_received(:new_regular)
      end

      it 'does not shuffle' do
        allow(shoe).to receive(:needs_to_shuffle?).and_return(false)
        game.deal_new_hand
        expect(shoe).to_not have_received(:new_regular)
      end
    end

    context 'when the dealer upcard is ace and player hand is not busted' do
      before do
        allow(game).to receive(:build_new_hand).and_return(player_hand)
        dealer_hand.cards << ace << ten
      end

      it 'asks about insurance' do
        allow(game).to receive(:ask_insurance)
        game.deal_new_hand
        expect(game).to have_received(:ask_insurance)
      end
    end

    context 'when the player hand is done' do
      before do
        allow(game).to receive(:build_new_hand).and_return(player_hand)
        allow(player_hand).to receive(:action?)
        allow(dealer_hand).to receive(:upcard_is_ace?).and_return(false)
        allow(game).to receive(:draw_bet_options)
        allow(player_hand).to receive(:done?).and_return(true)
      end

      it 'shows dealer down card' do
        game.deal_new_hand
        expect(dealer_hand.hide_down_card).to be_falsey
      end

      it 'hands are paid' do
        allow(game).to receive(:pay_hands)
        game.deal_new_hand
        expect(game).to have_received(:pay_hands)
      end

      it 'hands are drawn' do
        game.deal_new_hand
        expect(game).to have_received(:draw_hands)
      end

      it 'bet options are drawn' do
        game.deal_new_hand
        expect(game).to have_received(:draw_bet_options)
      end
    end
  end

  describe '#play_more_hands' do
    before do
      game.player_hands << player_hand
      allow(game).to receive(:current_player_hand).and_return(player_hand)
    end

    context 'when current hand is done' do
      it 'processes current player hand' do
        allow(player_hand).to receive(:done?).and_return(true)
        allow(player_hand).to receive(:process)
        game.play_more_hands
        expect(player_hand).to have_received(:process)
      end
    end

    context 'when current hand is not done' do
      before do
        allow(player_hand).to receive(:done?).and_return(false)
        allow(game).to receive(:draw_hands)
        allow(game).to receive(:draw_bet_options)
        allow(player_hand).to receive(:action?)
        game.dealer_hand = dealer_hand
        game.play_more_hands
      end

      it 'draws hands' do
        expect(game).to have_received(:draw_hands)
      end

      it 'gets current player hand action' do
        expect(player_hand).to have_received(:action?)
      end
    end
  end

  describe '#draw_hands' do
    before do
      player_hand.cards << ace << ten
      game.player_hands << player_hand
      dealer_hand.cards << ten << ten
      game.dealer_hand = dealer_hand
      allow(game).to receive(:puts)
    end

    it 'draws the hands' do
      game.draw_hands
      expected = "\n Dealer:\n 🂪 🂠  ⇒  10\n\n Player $100.00:\n 🂡 🂪  ⇒  21  $5.00 ⇐  \n\n"
      expect(game).to have_received(:puts).with(expected)
    end
  end

  describe '#new_bet' do
    before do
      game.dealer_hand = dealer_hand
      allow(STDIN).to receive(:gets).and_return('10')
      allow(described_class).to receive(:getc).and_return('s', 'q')
      allow(game).to receive(:print)
      allow(game).to receive(:puts)
      allow(game).to receive(:deal_new_hand)
      allow(game).to receive(:clear)
      allow(game).to receive(:draw_hands)
      allow(game).to receive(:normalize_current_bet)
    end

    it 'clears the screen' do
      game.new_bet
      expect(game).to have_received(:clear)
    end

    it 'draws hands' do
      game.new_bet
      expect(game).to have_received(:draw_hands)
    end

    it 'draws the current bet' do
      game.new_bet
      expected = " Current Bet: $5.00\n"
      expect(game).to have_received(:puts).with(expected)
    end

    it 'updates current bet' do
      game.new_bet
      expect(game.current_bet).to eq(1000)
    end

    it 'normalizes the bet' do
      game.new_bet
      expect(game).to have_received(:normalize_current_bet)
    end

    it 'deals a new hand' do
      game.new_bet
      expect(game).to have_received(:deal_new_hand)
    end
  end

  describe '#draw_game_options' do
    before do
      game.dealer_hand = dealer_hand
    end

    context 'when updating number of decks' do
      before do
        allow(described_class).to receive(:getc).and_return('n')
        allow(game).to receive(:clear)
        allow(game).to receive(:draw_hands)
        allow(game).to receive(:new_num_decks)
        allow(game).to receive(:puts)
      end

      it 'draws the game options' do
        game.draw_game_options
        expected = ' (N) Number of Decks  (T) Deck Type  (B) Back'
        expect(game).to have_received(:puts).with(expected)
      end

      it 'clears the screen' do
        game.draw_game_options
        expect(game).to have_received(:clear)
      end

      it 'draws the hands' do
        game.draw_game_options
        expect(game).to have_received(:draw_hands)
      end

      it 'updates number of decks' do
        game.draw_game_options
        expect(game).to have_received(:new_num_decks)
      end
    end

    context 'when updating the deck type' do
      before do
        allow(described_class).to receive(:getc).and_return('t')
        allow(game).to receive(:clear)
        allow(game).to receive(:draw_hands)
        allow(game).to receive(:new_deck_type)
        allow(game).to receive(:draw_bet_options)
        allow(game).to receive(:puts)
      end

      it 'clears the screen' do
        game.draw_game_options
        expect(game).to have_received(:clear).twice
      end

      it 'draws the hands' do
        game.draw_game_options
        expect(game).to have_received(:draw_hands).twice
      end

      it 'updates deck type' do
        game.draw_game_options
        expect(game).to have_received(:new_deck_type)
      end

      it 'draws the bet options' do
        game.draw_game_options
        expect(game).to have_received(:draw_bet_options)
      end
    end

    context 'when going back to previous menu' do
      before do
        allow(described_class).to receive(:getc).and_return('b')
        allow(game).to receive(:clear)
        allow(game).to receive(:draw_hands)
        allow(game).to receive(:draw_bet_options)
        allow(game).to receive(:puts)
      end

      it 'clears the screen' do
        game.draw_game_options
        expect(game).to have_received(:clear)
      end

      it 'draws the hands' do
        game.draw_game_options
        expect(game).to have_received(:draw_hands)
      end

      it 'draws the bet options' do
        game.draw_game_options
        expect(game).to have_received(:draw_bet_options)
      end
    end

    context 'when invalid input' do
      before do
        allow(described_class).to receive(:getc).and_return('x', 'b')
        allow(game).to receive(:puts)
        allow(game).to receive(:new_bet)
        allow(game).to receive(:draw_bet_options)
        allow(game).to receive(:draw_hands)
      end

      it 'gets the action again' do
        game.draw_game_options
        allow(game).to receive(:draw_game_options)
        expect(game).to have_received(:draw_bet_options).twice
      end
    end
  end

  describe '#new_num_decks' do
    before do
      game.dealer_hand = dealer_hand
      allow(STDIN).to receive(:gets).and_return('2')
      allow(described_class).to receive(:getc).and_return('b', 'q')
      allow(game).to receive(:print)
      allow(game).to receive(:puts)
      allow(game).to receive(:clear)
      allow(game).to receive(:draw_hands)
      allow(game).to receive(:draw_game_options)
      allow(game).to receive(:normalize_num_decks)
    end

    it 'clears screen' do
      game.new_num_decks
      expect(game).to have_received(:clear)
    end

    it 'draws hands' do
      game.new_num_decks
      expect(game).to have_received(:draw_hands)
    end

    it 'gets new number of decks' do
      game.new_num_decks
      expect(game.num_decks).to eq(2)
    end

    it 'normalizes number of decks' do
      game.new_num_decks
      expect(game).to have_received(:normalize_num_decks)
    end
  end

  describe '#normalize_num_decks' do
    it 'increases the value' do
      game.num_decks = 0
      game.normalize_num_decks
      expect(game.num_decks).to eq(1)
    end

    it 'decreases the value' do
      game.num_decks = 9
      game.normalize_num_decks
      expect(game.num_decks).to eq(8)
    end

    it 'leaves the value unaltered' do
      game.num_decks = 2
      game.normalize_num_decks
      expect(game.num_decks).to eq(2)
    end
  end

  describe '#new_deck_type' do
    before do
      game.dealer_hand = dealer_hand
      allow(game).to receive(:puts)
    end

    context 'when choosing a new deck type' do
      it 'draws options' do
        allow(described_class).to receive(:getc).and_return('1')
        game.new_deck_type
        expected = ' (1) Regular  (2) Aces  (3) Jacks  (4) Aces & Jacks  (5) Sevens  (6) Eights'
        expect(game).to have_received(:puts).with(expected)
      end

      it 'builds a new regular' do
        allow(described_class).to receive(:getc).and_return('1')
        allow(shoe).to receive(:new_regular)
        game.new_deck_type
        expect(shoe).to have_received(:new_regular)
      end

      it 'builds a new aces' do
        allow(described_class).to receive(:getc).and_return('2')
        allow(shoe).to receive(:new_aces)
        game.new_deck_type
        expect(shoe).to have_received(:new_aces)
      end

      it 'builds a new jacks' do
        allow(described_class).to receive(:getc).and_return('3')
        allow(shoe).to receive(:new_jacks)
        game.new_deck_type
        expect(shoe).to have_received(:new_jacks)
      end

      it 'builds a new aces_jacks' do
        allow(described_class).to receive(:getc).and_return('4')
        allow(shoe).to receive(:new_aces_jacks)
        game.new_deck_type
        expect(shoe).to have_received(:new_aces_jacks)
      end

      it 'builds a new sevens' do
        allow(described_class).to receive(:getc).and_return('5')
        allow(shoe).to receive(:new_sevens)
        game.new_deck_type
        expect(shoe).to have_received(:new_sevens)
      end

      it 'builds a new eights' do
        allow(described_class).to receive(:getc).and_return('6')
        allow(shoe).to receive(:new_eights)
        game.new_deck_type
        expect(shoe).to have_received(:new_eights)
      end
    end

    context 'when invalid input' do
      it 'gets the action again' do
        allow(described_class).to receive(:getc).and_return('x', '1')
        allow(game).to receive(:draw_hands)
        game.new_deck_type
        expect(game).to have_received(:draw_hands)
      end
    end
  end

  describe '#ask_insurance' do
    before do
      # game.dealer_hand = dealer_hand
      allow(game).to receive(:puts)
      allow(game).to receive(:insure_hand)
      allow(game).to receive(:no_insurance)
    end

    context 'when choosing to take insurance' do
      it 'draws options' do
        allow(described_class).to receive(:getc).and_return('y')
        game.ask_insurance
        expected = ' Insurance?  (Y) Yes  (N) No'
        expect(game).to have_received(:puts).with(expected)
      end

      it 'insures hand' do
        allow(described_class).to receive(:getc).and_return('y')
        game.ask_insurance
        expect(game).to have_received(:insure_hand)
      end

      it 'does not insure hand' do
        allow(described_class).to receive(:getc).and_return('n')
        game.ask_insurance
        expect(game).to have_received(:no_insurance)
      end
    end

    context 'when invalid input' do
      it 'asks again' do
        allow(described_class).to receive(:getc).and_return('x', 'y')
        allow(game).to receive(:draw_hands)
        game.ask_insurance
        expect(game).to have_received(:draw_hands)
      end
    end
  end

  describe '#insure_hand' do
    before do
      game.dealer_hand = dealer_hand
      game.player_hands << player_hand
      allow(game).to receive(:draw_hands)
      allow(game).to receive(:draw_bet_options)
    end

    it 'reduces hand bet' do
      game.insure_hand
      expect(player_hand.bet).to eq(250)
    end

    it 'sets hand as played' do
      game.insure_hand
      expect(player_hand.played).to be_truthy
    end

    it 'sets hand as payed' do
      game.insure_hand
      expect(player_hand.payed).to be_truthy
    end

    it 'sets hand status as LOST' do
      game.insure_hand
      expect(player_hand.status).to eq(LOST)
    end

    it 'updates game money' do
      game.insure_hand
      expect(game.money).to eq(9750)
    end

    it 'draws hands' do
      game.insure_hand
      expect(game).to have_received(:draw_hands)
    end

    it 'draws bet options' do
      game.insure_hand
      expect(game).to have_received(:draw_bet_options)
    end
  end

  describe '#no_insurance' do
    before do
      game.dealer_hand = dealer_hand
      game.player_hands << player_hand
      allow(player_hand).to receive(:action?)
      allow(game).to receive(:draw_bet_options)
      allow(game).to receive(:draw_hands)
      allow(game).to receive(:pay_hands)
    end

    context 'when dealer hand is blackjack' do
      before do
        dealer_hand.cards << ace << ten
      end

      it 'shows dealer down card' do
        game.no_insurance
        expect(dealer_hand.hide_down_card).to be_falsey
      end

      it 'pays hands' do
        game.no_insurance
        expect(game).to have_received(:pay_hands)
      end

      it 'draws hands' do
        game.no_insurance
        expect(game).to have_received(:draw_hands)
      end

      it 'draws bet options' do
        game.no_insurance
        expect(game).to have_received(:draw_bet_options)
      end
    end

    context 'when dealer hand is not blackjack' do
      before do
        dealer_hand.cards << ace << seven
        allow(game).to receive(:play_dealer_hand)
      end

      it 'plays dealer hand' do
        allow(player_hand).to receive(:done?).and_return(true)
        game.no_insurance
        expect(game).to have_received(:play_dealer_hand)
      end

      it 'draws hands' do
        allow(player_hand).to receive(:done?).and_return(false)
        game.no_insurance
        expect(game).to have_received(:draw_hands)
      end

      it 'gets player hand action' do
        allow(player_hand).to receive(:done?).and_return(false)
        game.no_insurance
        expect(player_hand).to have_received(:action?)
      end
    end
  end

  describe '#play_dealer_hand' do
    before do
      game.dealer_hand = dealer_hand
      allow(dealer_hand).to receive(:play)
      allow(game).to receive(:draw_bet_options)
      allow(game).to receive(:draw_hands)
    end

    it 'plays dealer hand' do
      game.play_dealer_hand
      expect(dealer_hand).to have_received(:play)
    end

    it 'draws bet options' do
      game.play_dealer_hand
      expect(game).to have_received(:draw_bet_options)
    end

    it 'draws hands' do
      game.play_dealer_hand
      expect(game).to have_received(:draw_hands)
    end
  end

  describe '#split_current_hand' do
    before do
      game.dealer_hand = dealer_hand
      game.player_hands << player_hand
      allow(game).to receive(:current_player_hand).and_return(player_hand)
    end

    context 'when current hand can split' do
      before do
        player_hand.cards << six << six
        allow(described_class).to receive(:getc).and_return('s', 's')
        allow(game).to receive(:draw_bet_options)
        allow(game).to receive(:draw_hands)
        allow(player_hand).to receive(:action?)
      end

      it 'splits hand' do
        game.split_current_hand
        expect(game.player_hands.size).to eq(2)
      end

      it 'first hand is done' do
        allow(player_hand).to receive(:done?).and_return(true)
        game.split_current_hand
        expect(player_hand).to have_received(:done?).twice
      end
    end

    context 'when current hand cannot split' do
      before do
        player_hand.cards << ace << six
        allow(described_class).to receive(:getc).and_return('s')
        allow(game).to receive(:draw_bet_options)
        allow(game).to receive(:draw_hands)
        allow(player_hand).to receive(:action?)
      end

      it 'draws hands' do
        game.split_current_hand
        expect(game).to have_received(:draw_hands)
      end

      it 'gets player hand action' do
        game.split_current_hand
        expect(player_hand).to have_received(:action?)
      end
    end
  end
end
