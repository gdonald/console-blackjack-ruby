# frozen_string_literal: true

RSpec.describe Game do
  let(:shoe) { build(:shoe, :new_regular) }
  let(:game) { build(:game, shoe: shoe) }
  let(:player_hand) { build(:player_hand, game: game) }

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
end
