# frozen_string_literal: true

RSpec.describe PlayerHand do
  let(:shoe) { build(:shoe, :new_regular) }
  let(:game) { build(:game, shoe: shoe) }
  let(:player_hand) { build(:player_hand, game: game) }
  let(:ace) { build(:card, :ace) }
  let(:six) { build(:card, :six) }
  let(:seven) { build(:card, :seven) }
  let(:eight) { build(:card, :eight) }
  let(:nine) { build(:card, :nine) }
  let(:ten) { build(:card, :ten) }

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

  describe '#done?' do
    context 'when played' do
      it 'returns true' do
        player_hand.played = true
        expect(player_hand).to be_done
      end
    end

    context 'when stood' do
      it 'returns true' do
        player_hand.stood = true
        expect(player_hand).to be_done
      end
    end

    context 'when blackjack' do
      it 'returns true' do
        player_hand.cards << ace << ten
        expect(player_hand).to be_done
      end
    end

    context 'when busted' do
      it 'returns true' do
        player_hand.cards << ten << ten << ten
        expect(player_hand).to be_done
      end
    end

    context 'when soft count of 21' do
      it 'returns true' do
        player_hand.cards << ace << ace << nine
        expect(player_hand).to be_done
      end
    end

    context 'when hard count of 21' do
      it 'returns true' do
        player_hand.cards << ace << ten << ten
        expect(player_hand).to be_done
      end
    end

    context 'when pair of sevens' do
      it 'returns false' do
        player_hand.cards << seven << seven
        expect(player_hand).to_not be_done
      end
    end
  end

  describe '#can_split?' do
    context 'when stood' do
      it 'returns false' do
        player_hand.stood = true
        expect(player_hand).to_not be_can_split
      end
    end

    context 'when MAX_PLAYER_HANDS' do
      it 'returns false' do
        6.times { game.player_hands << build(:player_hand) }
        expect(player_hand).to_not be_can_split
      end
    end

    context 'when not enough money' do
      it 'returns false' do
        game.money = 9999
        expect(player_hand).to_not be_can_split
      end
    end

    context 'when more than 2 cards' do
      it 'returns false' do
        player_hand.cards << ace << ace << ace
        expect(player_hand).to_not be_can_split
      end
    end

    context 'when card values do not match' do
      it 'returns false' do
        player_hand.cards << seven << nine
        expect(player_hand).to_not be_can_split
      end
    end

    context 'when card values match' do
      it 'returns true' do
        player_hand.cards << seven << seven
        expect(player_hand).to be_can_split
      end
    end
  end

  describe '#can_dbl?' do
    context 'when not enough money' do
      it 'returns false' do
        game.money = 9999
        expect(player_hand).to_not be_can_dbl
      end
    end

    context 'when stood' do
      it 'returns false' do
        player_hand.stood = true
        expect(player_hand).to_not be_can_dbl
      end
    end

    context 'when more than 2 cards' do
      it 'returns false' do
        player_hand.cards << ace << ace << ace
        expect(player_hand).to_not be_can_dbl
      end
    end

    context 'when blackjack' do
      it 'returns false' do
        player_hand.cards << ace << ten
        expect(player_hand).to_not be_can_dbl
      end
    end

    context 'when a pair of sixes' do
      it 'returns true' do
        player_hand.cards << six << six
        expect(player_hand).to be_can_dbl
      end
    end
  end

  describe '#can_stand?' do
    context 'when stood' do
      it 'returns false' do
        player_hand.stood = true
        expect(player_hand).to_not be_can_stand
      end
    end

    context 'when blackjack' do
      it 'returns false' do
        player_hand.cards << ace << ten
        expect(player_hand).to_not be_can_stand
      end
    end

    context 'when busted' do
      it 'returns false' do
        player_hand.cards << eight << eight << eight
        expect(player_hand).to_not be_can_stand
      end
    end

    context 'when a pair of sixes' do
      it 'returns true' do
        player_hand.cards << six << six
        expect(player_hand).to be_can_stand
      end
    end
  end

  describe '#can_hit?' do
    context 'when played' do
      it 'returns false' do
        player_hand.played = true
        expect(player_hand).to_not be_can_hit
      end
    end

    context 'when stood' do
      it 'returns false' do
        player_hand.stood = true
        expect(player_hand).to_not be_can_hit
      end
    end

    context 'when blackjack' do
      it 'returns false' do
        player_hand.cards << ace << ten
        expect(player_hand).to_not be_can_hit
      end
    end

    context 'when busted' do
      it 'returns false' do
        player_hand.cards << eight << eight << eight
        expect(player_hand).to_not be_can_hit
      end
    end

    context 'when a hard 21' do
      it 'returns false' do
        player_hand.cards << seven << seven << seven
        expect(player_hand).to_not be_can_hit
      end
    end

    context 'when a pair of sixes' do
      it 'returns true' do
        player_hand.cards << six << six
        expect(player_hand).to be_can_hit
      end
    end
  end

  # describe '#hit' do
  #   context 'when not done' do
  #     it 'adds a card to the hand' do
  #       allow(game).to receive(:draw_hands)
  #       allow(game).to receive(:current_player_hand) { player_hand }
  #       allow(player_hand).to receive(:action?)
  #       expect { player_hand.hit }.to change { player_hand.cards.size }.by(1)
  #     end
  #   end
  #
  #   context 'when done' do
  #     let(:dealer_hand) { build(:dealer_hand, game: game) }
  #
  #     it 'adds a card to the hand' do
  #       game.dealer_hand = dealer_hand
  #       allow(player_hand).to receive(:done?).and_return(true)
  #       allow(STDIN).to receive(:getc).and_return('q')
  #       expect { player_hand.hit }.to change { player_hand.cards.size }.by(1)
  #     end
  #   end
  # end
  #
  # describe '#dbl' do
  #   it 'adds a card, doubles the bet, ends the hand' do
  #     # game.dealer_hand = dealer_hand
  #     # allow(player_hand).to receive(:done?).and_return(true)
  #     # allow(STDIN).to receive(:getc).and_return('q')
  #     expect { player_hand.dbl }.to change { player_hand.cards.size }.by(1)
  #   end
  # end
end
