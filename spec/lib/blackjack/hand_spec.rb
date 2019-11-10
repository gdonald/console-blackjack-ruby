# frozen_string_literal: true

RSpec.describe Hand do
  let(:shoe) { build(:shoe, :new_regular) }
  let(:blackjack) { build(:blackjack, shoe: shoe) }
  let(:hand) { build(:hand, blackjack: blackjack) }

  describe '.new' do
    it 'creates a hand' do
      expect(hand).to be
    end

    it 'has a blackjack' do
      expect(hand.blackjack).to eq(blackjack)
    end
  end

  describe '#deal_card' do
    it 'adds a card to the hand' do
      expect do
        hand.deal_card
      end.to change { hand.cards.size }.by(1)
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
