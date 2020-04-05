# coding: utf-8
# frozen_string_literal: true

RSpec.describe Card do
  let(:card) { build(:card) }

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
    it 'returns a string value' do
      expect(card.to_s).to eq('🂡')
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
end
