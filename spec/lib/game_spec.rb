# frozen_string_literal: true

RSpec.describe Game do
  let(:shoe) { build(:shoe, :new_regular) }
  let(:game) { build(:game, shoe: shoe) }
  let(:player_hand) { build(:player_hand, game: game) }
  let(:dealer_hand) { build(:dealer_hand, game: game) }

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
end
