# frozen_string_literal: true

RSpec.describe Draw do
  let(:shoe) { build(:shoe, :new_regular) }
  let(:blackjack) { build(:blackjack, shoe: shoe) }
  let(:player_hand) { build(:player_hand, blackjack: blackjack) }
  let(:ace) { build(:card, :ace) }
  let(:ten) { build(:card, :ten) }

  describe '.player_hands' do
    it 'draws the hand' do
      player_hand.cards << ace << ten
      expected = " 🂡 🂪  ⇒  21  $5.00  \n\n"
      expect(described_class.player_hand(blackjack, player_hand, 1)).to eq(expected)
    end

    it 'draws a lost hand' do
      player_hand.cards << ace << ace
      player_hand.status = LOST
      expected = " 🂡 🂡  ⇒  12  -$5.00  Lose!\n\n"
      expect(described_class.player_hand(blackjack, player_hand, 1)).to eq(expected)
    end

    it 'draws a won hand' do
      player_hand.cards << ace << ace
      player_hand.status = WON
      expected = " 🂡 🂡  ⇒  12  +$5.00  Won!\n\n"
      expect(described_class.player_hand(blackjack, player_hand, 1)).to eq(expected)
    end

    it 'draws a push hand' do
      player_hand.cards << ace << ace
      player_hand.status = PUSH
      expected = " 🂡 🂡  ⇒  12  $5.00  Push\n\n"
      expect(described_class.player_hand(blackjack, player_hand, 1)).to eq(expected)
    end
  end
end
