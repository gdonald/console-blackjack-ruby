# coding: utf-8
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
      expect(game.more_hands_to_play?).to be_falsey
    end

    it 'returns true' do
      game.player_hands << player_hand << player_hand
      expect(game.more_hands_to_play?).to be_truthy
    end
  end
end
