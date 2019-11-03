# frozen_string_literal: true

RSpec.describe DealerHand do
  let(:game) { build(:game) }
  let(:dealer_hand) { build(:dealer_hand, game: game) }
  let(:ace) { build(:card, :ace) }
  let(:six) { build(:card, :six) }
  let(:seven) { build(:card, :seven) }
  let(:eight) { build(:card, :eight) }
  let(:nine) { build(:card, :nine) }
  let(:ten) { build(:card, :ten) }

  describe '.new' do
    it 'creates a dealer_hand' do
      expect(dealer_hand).to be
    end

    it 'has a game' do
      expect(dealer_hand.game).to eq(game)
    end
  end

  describe '#busted?' do
    it 'returns false' do
      expect(dealer_hand).to_not be_busted
    end

    it 'returns true' do
      dealer_hand.cards << ten << ten << ten
      dealer_hand.hide_down_card = false
      expect(dealer_hand).to be_busted
    end
  end

  describe '#value' do
    context 'with a soft count' do
      it 'returns 10' do
        dealer_hand.cards << ten << ace
        expect(dealer_hand.value(Hand::CountMethod::SOFT)).to eq(10)
      end

      it 'returns 11' do
        dealer_hand.cards << ace << ten
        expect(dealer_hand.value(Hand::CountMethod::SOFT)).to eq(11)
      end

      it 'returns 12' do
        dealer_hand.cards << ten << ace << ace
        dealer_hand.hide_down_card = false
        expect(dealer_hand.value(Hand::CountMethod::SOFT)).to eq(12)
      end
    end

    context 'with a hard count' do
      it 'returns 10' do
        dealer_hand.cards << ten << ace
        expect(dealer_hand.value(Hand::CountMethod::HARD)).to eq(10)
      end

      it 'returns 1' do
        dealer_hand.cards << ace << ten
        expect(dealer_hand.value(Hand::CountMethod::HARD)).to eq(1)
      end
    end
  end

  describe '#upcard_is_ace?' do
    it 'returns false' do
      dealer_hand.cards << ten << ace
      expect(dealer_hand).to_not be_upcard_is_ace
    end

    it 'returns true' do
      dealer_hand.cards << ace << ten
      expect(dealer_hand).to be_upcard_is_ace
    end
  end

  describe '#draw' do
    it 'returns " 🂪 🂠  ⇒  10"' do
      dealer_hand.cards << ten << ace
      expected = ' 🂪 🂠  ⇒  10'
      expect(dealer_hand.draw).to eq(expected)
    end

    it 'returns " 🂡 🂠  ⇒  11"' do
      dealer_hand.cards << ace << ten
      expected = ' 🂡 🂠  ⇒  11'
      expect(dealer_hand.draw).to eq(expected)
    end

    it 'returns " 🂡 🂪  ⇒  21"' do
      dealer_hand.cards << ace << ten
      dealer_hand.hide_down_card = false
      expected = ' 🂡 🂪  ⇒  21'
      expect(dealer_hand.draw).to eq(expected)
    end
  end
end
