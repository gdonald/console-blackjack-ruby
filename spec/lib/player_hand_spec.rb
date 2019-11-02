# frozen_string_literal: true

RSpec.describe PlayerHand do
  let(:game) { build(:game) }
  let(:player_hand) { build(:player_hand, game: game) }
  let(:ten) { build(:card, :ten) }
  let(:ace) { build(:card, :ace) }

  describe '.new' do
    it 'creates a player_hand' do
      expect(player_hand).to be
    end

    it 'has a game' do
      expect(player_hand.game).to eq(game)
    end

    it 'has a bet' do
      expect(player_hand.bet).to eq(500)
    end

    it 'has an unknown status' do
      expect(player_hand.status).to eq(Hand::Status::UNKNOWN)
    end

    it 'has not been payed' do
      expect(player_hand.payed).to be_falsey
    end
  end

  describe '#busted?' do
    it 'returns false' do
      expect(player_hand).to_not be_busted
    end

    it 'returns true' do
      player_hand.cards << ten << ten << ten
      expect(player_hand).to be_busted
    end
  end

  describe '#value' do
    context 'with a soft count' do
      it 'returns 21' do
        player_hand.cards << ten << ace
        expect(player_hand.value(Hand::CountMethod::SOFT)).to eq(21)
      end

      it 'returns 12' do
        player_hand.cards << ten << ace << ace
        expect(player_hand.value(Hand::CountMethod::SOFT)).to eq(12)
      end
    end

    context 'with a hard count' do
      it 'returns 11' do
        player_hand.cards << ten << ace
        expect(player_hand.value(Hand::CountMethod::HARD)).to eq(11)
      end
    end
  end
end
