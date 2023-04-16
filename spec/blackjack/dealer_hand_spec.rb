# frozen_string_literal: true

RSpec.describe DealerHand do
  let(:shoe) { build(:shoe, :new_regular) }
  let(:blackjack) { build(:blackjack) }
  let(:dealer_hand) { build(:dealer_hand, blackjack:) }
  let(:ace) { build(:card, :ace, blackjack:) }
  let(:ten) { build(:card, :ten, blackjack:) }

  describe '.new' do
    it 'creates a dealer_hand' do
      expect(dealer_hand).to be
    end

    it 'has a blackjack' do
      expect(dealer_hand.blackjack).to eq(blackjack)
    end
  end

  describe '#busted?' do
    it 'returns false' do
      expect(dealer_hand).to_not be_busted
    end

    it 'returns true' do
      dealer_hand.cards << ten << ten << ten
      dealer_hand.hide_first_card = false
      expect(dealer_hand).to be_busted
    end
  end

  describe '#value' do
    context 'with a soft count' do
      it 'returns 10' do
        dealer_hand.cards << ace << ten
        expect(dealer_hand.value(:soft)).to eq(10)
      end

      it 'returns 11' do
        dealer_hand.cards << ten << ace
        expect(dealer_hand.value(:soft)).to eq(11)
      end

      it 'returns 12' do
        dealer_hand.cards << ten << ace << ace
        dealer_hand.hide_first_card = false
        expect(dealer_hand.value(:soft)).to eq(12)
      end
    end

    context 'with a hard count' do
      it 'returns 10' do
        dealer_hand.cards << ace << ten
        expect(dealer_hand.value(:hard)).to eq(10)
      end

      it 'returns 1' do
        dealer_hand.cards << ten << ace
        expect(dealer_hand.value(:hard)).to eq(1)
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
    it 'returns " 🂠 🂪 ⇒ 10"' do
      dealer_hand.cards << ace << ten
      expected = ' 🂠 🂪  ⇒  10'
      expect(dealer_hand.draw).to eq(expected)
    end

    it 'returns " 🂠 🂡 ⇒ 11"' do
      dealer_hand.cards << ten << ace
      expected = ' 🂠 🂡  ⇒  11'
      expect(dealer_hand.draw).to eq(expected)
    end

    it 'returns " 🂡 🂪 ⇒ 21"' do
      dealer_hand.cards << ace << ten
      dealer_hand.hide_first_card = false
      expected = ' 🂡 🂪  ⇒  21'
      expect(dealer_hand.draw).to eq(expected)
    end
  end

  describe '#both_values' do
    context 'with a soft count' do
      it 'returns [10, 10]' do
        dealer_hand.cards << ace << ten
        expect(dealer_hand.both_values).to eq([10, 10])
      end

      it 'returns [11, 1]' do
        dealer_hand.cards << ten << ace
        expect(dealer_hand.both_values).to eq([11, 1])
      end

      it 'returns [12, 12]' do
        dealer_hand.cards << ten << ace << ace
        dealer_hand.hide_first_card = false
        expect(dealer_hand.both_values).to eq([12, 12])
      end
    end

    context 'with a hard count' do
      it 'returns [10, 10]' do
        dealer_hand.cards << ace << ten
        expect(dealer_hand.both_values).to eq([10, 10])
      end

      it 'returns [11, 1]' do
        dealer_hand.cards << ten << ace
        expect(dealer_hand.both_values).to eq([11, 1])
      end
    end
  end

  describe '#deal_required_cards' do
    before do
      blackjack.shoe = build(:shoe, :new_regular)
    end

    context 'when soft is < 18' do
      it 'deals cards' do
        dealer_hand.cards << ace << build(:card, :seven)
        dealer_hand.deal_required_cards
        expect(dealer_hand.cards.size >= 3).to be_truthy
      end
    end

    context 'when hard is < 17' do
      it 'deals cards' do
        dealer_hand.cards << ace << ten << build(:card, :five)
        dealer_hand.deal_required_cards
        expect(dealer_hand.cards.size >= 4).to be_truthy
      end
    end
  end

  describe '#play' do
    before do
      blackjack.dealer_hand = dealer_hand
    end

    it 'plays the dealer hand' do
      dealer_hand.play
      expect(dealer_hand.played).to be_truthy
    end

    it 'pays hands' do
      allow(blackjack).to receive(:pay_hands)
      dealer_hand.play
      expect(blackjack).to have_received(:pay_hands)
    end

    context 'when does not need to play dealer hand' do
      before do
        allow(blackjack).to receive(:need_to_play_dealer_hand?).and_return(false)
      end

      it 'hides down card when no blackjack' do
        allow(dealer_hand).to receive(:blackjack?).and_return(false)
        dealer_hand.play
        expect(dealer_hand.hide_first_card).to be_truthy
      end

      it 'shows down card if blackjack' do
        allow(dealer_hand).to receive(:blackjack?).and_return(true)
        dealer_hand.play
        expect(dealer_hand.hide_first_card).to be_falsey
      end

      it 'does not deal any cards' do
        allow(dealer_hand).to receive(:deal_required_cards)
        dealer_hand.play
        expect(dealer_hand).to_not have_received(:deal_required_cards)
      end
    end

    context 'when need to play dealer hand' do
      before do
        blackjack.shoe = shoe
        allow(blackjack).to receive(:need_to_play_dealer_hand?).and_return(true)
      end

      it 'shows down card if not blackjack' do
        allow(dealer_hand).to receive(:blackjack?).and_return(false)
        dealer_hand.play
        expect(dealer_hand.hide_first_card).to be_falsey
      end

      it 'shows down card if blackjack' do
        allow(dealer_hand).to receive(:blackjack?).and_return(true)
        dealer_hand.play
        expect(dealer_hand.hide_first_card).to be_falsey
      end

      it 'deals required cards' do
        allow(dealer_hand).to receive(:deal_required_cards)
        dealer_hand.play
        expect(dealer_hand).to have_received(:deal_required_cards)
      end
    end
  end
end
