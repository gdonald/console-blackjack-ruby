# frozen_string_literal: true

RSpec.describe Card do
  let(:blackjack) { build(:blackjack) }
  let(:card) { build(:card, blackjack:) }

  describe '.new' do
    it 'creates a card' do
      expect(card).to be
    end

    it 'has a value' do
      expect(card.value).to eq(0)
    end

    it 'has a suit' do
      expect(card.suit).to eq(0)
    end
  end

  describe '#to_s' do
    context 'with regular faces' do
      it 'returns a string value' do
        expect(card.to_s).to eq('🂡')
      end
    end

    context 'with alternate faces' do
      before do
        blackjack.face_type = 2
      end

      it 'returns a string value' do
        expect(card.to_s).to eq('A♠')
      end
    end
  end

  describe '#ace?' do
    it 'returns true' do
      expect(card).to be_ace
    end

    it 'returns false' do
      card = build(:card, :two)
      expect(card).not_to be_ace
    end
  end

  describe '#ten?' do
    it 'returns true' do
      card = build(:card, :ten)
      expect(card).to be_ten
    end

    it 'returns false' do
      expect(card).not_to be_ten
    end
  end

  describe '.faces' do
    it 'returns a five of clubs' do
      expect(described_class.faces[4][3]).to eq('🃕')
    end
  end

  describe '.value' do
    let(:card) { build(:card, blackjack:) }
    let(:count_method) { :soft }
    let(:total) { 0 }
    let(:result) { described_class.value(card, count_method, total) }

    it 'returns 11' do
      expect(result).to eq(11)
    end

    context 'with a hard count' do
      let(:count_method) { :hard }

      it 'returns 1' do
        expect(result).to eq(1)
      end
    end

    context 'with a total of 11' do
      let(:total) { 11 }

      it 'returns 1' do
        expect(result).to eq(1)
      end
    end

    context 'with a face card' do
      let(:card) { build(:card, :jack, blackjack:) }

      it 'returns 10' do
        expect(result).to eq(10)
      end
    end
  end
end
