# frozen_string_literal: true

RSpec.describe Shoe do
  let(:shoe) { build(:shoe) }

  describe '.new' do
    it 'creates a shoe' do
      expect(shoe).to be
    end

    it 'has a number of decks' do
      expect(shoe.num_decks).to eq(1)
    end
  end

  describe '#needs_to_shuffle?' do
    context 'with an empty shoe' do
      it 'returns true' do
        expect(shoe).to be_needs_to_shuffle
      end
    end

    context 'with a new regular shoe' do
      let(:shoe) { build(:shoe, :new_regular) }

      it 'returns false' do
        expect(shoe).to_not be_needs_to_shuffle
      end
    end

    context 'with 42 cards being dealt' do
      let(:shoe) { build(:shoe, :new_regular) }

      before do
        42.times { shoe.next_card }
      end

      it 'returns true' do
        expect(shoe).to be_needs_to_shuffle
      end
    end
  end

  describe '#shuffle' do
    let(:shoe) { build(:shoe) }

    it 'calls shuffle' do
      cards = instance_double(Array)
      allow(cards).to receive(:shuffle!)
      allow(shoe).to receive(:cards).and_return(cards)
      shoe.shuffle
      expect(cards).to have_received(:shuffle!).exactly(7).times
    end
  end

  describe '#new_regular' do
    let(:shoe) { build(:shoe) }

    it 'creates a shoe' do
      shoe.new_regular
      expect(shoe.cards.size).to eq(52)
    end

    it 'calls shuffle' do
      allow(shoe).to receive(:shuffle)
      shoe.new_regular
      expect(shoe).to have_received(:shuffle)
    end
  end

  describe '#new_aces' do
    let(:shoe) { build(:shoe) }

    it 'creates a shoe' do
      shoe.new_aces
      expect(shoe.cards.size).to eq(40)
    end

    it 'calls shuffle' do
      allow(shoe).to receive(:shuffle)
      shoe.new_aces
      expect(shoe).to have_received(:shuffle)
    end
  end

  describe '#new_jacks' do
    let(:shoe) { build(:shoe) }

    it 'creates a shoe' do
      shoe.new_jacks
      expect(shoe.cards.size).to eq(40)
    end

    it 'calls shuffle' do
      allow(shoe).to receive(:shuffle)
      shoe.new_jacks
      expect(shoe).to have_received(:shuffle)
    end
  end

  describe '#new_aces_jacks' do
    let(:shoe) { build(:shoe) }

    it 'creates a shoe' do
      shoe.new_aces_jacks
      expect(shoe.cards.size).to eq(80)
    end

    it 'calls shuffle' do
      allow(shoe).to receive(:shuffle)
      shoe.new_aces_jacks
      expect(shoe).to have_received(:shuffle)
    end
  end

  describe '#new_sevens' do
    let(:shoe) { build(:shoe) }

    it 'creates a shoe' do
      shoe.new_sevens
      expect(shoe.cards.size).to eq(40)
    end

    it 'calls shuffle' do
      allow(shoe).to receive(:shuffle)
      shoe.new_sevens
      expect(shoe).to have_received(:shuffle)
    end
  end

  describe '#new_eights' do
    let(:shoe) { build(:shoe) }

    it 'creates a shoe' do
      shoe.new_eights
      expect(shoe.cards.size).to eq(40)
    end

    it 'calls shuffle' do
      allow(shoe).to receive(:shuffle)
      shoe.new_eights
      expect(shoe).to have_received(:shuffle)
    end
  end

  describe '#next_card' do
    let(:shoe) { build(:shoe, :new_regular) }

    it 'removes the next card' do
      shoe.next_card
      expect(shoe.cards.size).to eq(51)
    end

    it 'returns a Card' do
      expect(shoe.next_card).to be_an_instance_of(Card)
    end
  end

  describe '.shuffle_specs' do
    it 'returns spec for when to shuffle' do
      expect(described_class.shuffle_specs).to eq([80, 81, 82, 84, 86, 89, 92, 95])
    end
  end
end
