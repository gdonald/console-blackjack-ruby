# frozen_string_literal: true

RSpec.describe Hand do
  let(:game) { build(:game) }
  let(:hand) { build(:hand, game: game) }

  describe '.new' do
    it 'creates a hand' do
      expect(hand).to be
    end

    it 'has a game' do
      expect(hand.game).to eq(game)
    end
  end

  describe '#blackjack?' do
    context 'with an empty hand' do
      it 'returns false' do
        expect(hand).to_not be_blackjack
      end
    end

    context 'with two cards' do
      let(:ace) { build(:card, :ace) }
      let(:ten) { build(:card, :ten) }

      it 'an ace and a ten returns true' do
        hand.cards << ace << ten
        expect(hand).to be_blackjack
      end

      it 'a ten and an ace returns true' do
        hand.cards << ten << ace
        expect(hand).to be_blackjack
      end

      it 'two aces returns false' do
        hand.cards << ace << ace
        expect(hand).to_not be_blackjack
      end
    end
  end
end
