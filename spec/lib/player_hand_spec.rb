# coding: utf-8
# frozen_string_literal: true

RSpec.describe PlayerHand do
  let(:shoe) { build(:shoe, :new_regular) }
  let(:game) { build(:game, shoe: shoe) }
  let(:player_hand) { build(:player_hand, game: game) }
  let(:dealer_hand) { build(:dealer_hand, game: game) }
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
      expect(player_hand.status).to eq(UNKNOWN)
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
        expect(player_hand.value(SOFT)).to eq(21)
      end

      it 'returns 12' do
        player_hand.cards << ten << ace << ace
        expect(player_hand.value(SOFT)).to eq(12)
      end
    end

    context 'with a hard count' do
      it 'returns 11' do
        player_hand.cards << ten << ace
        expect(player_hand.value(HARD)).to eq(11)
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

  describe '#draw' do
    it 'draws the hand' do
      player_hand.cards << ace << ten
      expected = " 🂡 🂪  ⇒  21  $5.00  \n\n"
      expect(player_hand.draw(1)).to eq(expected)
    end

    it 'draws a lost hand' do
      player_hand.cards << ace << ace
      player_hand.status = LOST
      expected = " 🂡 🂡  ⇒  12  -$5.00  Lose!\n\n"
      expect(player_hand.draw(1)).to eq(expected)
    end

    it 'draws a won hand' do
      player_hand.cards << ace << ace
      player_hand.status = WON
      expected = " 🂡 🂡  ⇒  12  +$5.00  Won!\n\n"
      expect(player_hand.draw(1)).to eq(expected)
    end

    it 'draws a push hand' do
      player_hand.cards << ace << ace
      player_hand.status = PUSH
      expected = " 🂡 🂡  ⇒  12  $5.00  Push\n\n"
      expect(player_hand.draw(1)).to eq(expected)
    end
  end

  describe '#process' do
    context 'with more hands to play' do
      before do
        allow(game).to receive(:more_hands_to_play?).and_return(true)
        allow(game).to receive(:play_more_hands)
      end

      it 'plays more hands' do
        player_hand.process
        expect(game).to have_received(:play_more_hands)
      end
    end

    context 'with no more hands to play' do
      before do
        allow(game).to receive(:more_hands_to_play?).and_return(false)
        allow(game).to receive(:play_dealer_hand)
      end

      it 'plays dealer hand' do
        player_hand.process
        expect(game).to have_received(:play_dealer_hand)
      end
    end
  end

  describe '#hit' do
    before do
      game.dealer_hand = dealer_hand
    end

    context 'when done' do
      let(:dealer_hand) { build(:dealer_hand, game: game) }

      before do
        allow(player_hand).to receive(:done?).and_return(true)
        allow(player_hand).to receive(:process)
      end

      it 'adds a card to the hand' do
        expect { player_hand.hit }.to change { player_hand.cards.size }.by(1)
      end
    end

    context 'when not done' do
      before do
        allow(player_hand).to receive(:done?).and_return(false)
        allow(game).to receive(:current_player_hand).and_return(player_hand)
        allow(player_hand).to receive(:action?)
        allow(game).to receive(:draw_hands)
      end

      it 'adds a card to the hand' do
        expect { player_hand.hit }.to change { player_hand.cards.size }.by(1)
      end
    end
  end

  describe '#dbl' do
    before do
      game.dealer_hand = dealer_hand
      allow(game).to receive(:draw_hands)
      allow(game).to receive(:draw_bet_options)
      allow(player_hand).to receive(:process)
    end

    context 'when done' do
      before do
        allow(player_hand).to receive(:done?).and_return(true)
        player_hand.dbl
      end

      it 'adds a card to the hand' do
        expect(player_hand.cards.size).to eq(1)
      end

      it 'sets hand to played' do
        expect(player_hand.played).to be_truthy
      end

      it 'doubles the bet' do
        expect(player_hand.bet).to eq(1000)
      end

      it 'calls process' do
        expect(player_hand).to have_received(:process)
      end
    end

    context 'when not done' do
      before do
        allow(player_hand).to receive(:done?).and_return(false)
        player_hand.dbl
      end

      it 'does not call process' do
        expect(player_hand).to_not have_received(:process)
      end
    end
  end

  describe '#stand' do
    before do
      allow(player_hand).to receive(:process)
      allow(game).to receive(:draw_hands)
      allow(game).to receive(:draw_bet_options)
      game.dealer_hand = dealer_hand
      player_hand.stand
    end

    it 'sets the hand as stood' do
      expect(player_hand.stood).to be_truthy
    end

    it 'sets the hand as played' do
      expect(player_hand.played).to be_truthy
    end

    it 'calls process' do
      expect(player_hand).to have_received(:process)
    end
  end

  describe '#action?' do
    before do
      player_hand.cards << ace << ace
      game.player_hands << player_hand
      game.dealer_hand = dealer_hand
      allow(player_hand).to receive(:puts)
    end

    context 'when standing' do
      before do
        allow(Game).to receive(:getc).and_return('s', 'q')
        allow(player_hand).to receive(:stand)
      end

      it 'stands the hand' do
        player_hand.action?
        expect(player_hand).to have_received(:stand)
      end
    end

    context 'when hitting' do
      before do
        allow(Game).to receive(:getc).and_return('h', 'q')
        allow(player_hand).to receive(:hit)
      end

      it 'hits the hand' do
        player_hand.action?
        expect(player_hand).to have_received(:hit)
      end
    end

    context 'when doubling' do
      before do
        allow(Game).to receive(:getc).and_return('d', 'q')
        allow(player_hand).to receive(:dbl)
      end

      it 'doubles the hand' do
        player_hand.action?
        expect(player_hand).to have_received(:dbl)
      end
    end

    context 'when splitting' do
      before do
        allow(Game).to receive(:getc).and_return('p', 'q')
        allow(game).to receive(:split_current_hand)
      end

      it 'splits the hand' do
        player_hand.action?
        expect(game).to have_received(:split_current_hand)
      end
    end

    context 'when invalid input' do
      before do
        allow(Game).to receive(:getc).and_return('x', 's', 'q') # ?, split, quit
        allow(game).to receive(:clear)
        allow(game).to receive(:draw_hands)
        allow(game).to receive(:puts)
      end

      it 'gets the action again' do
        expect { player_hand.action? }.to raise_error(SystemExit)
      end
    end
  end

  describe '#pay' do

  end
end
