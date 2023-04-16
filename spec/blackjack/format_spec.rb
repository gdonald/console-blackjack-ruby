# frozen_string_literal: true

RSpec.describe Format do
  describe '#money' do
    it 'returns a formatted money string' do
      str = described_class.money(1)
      expect(str).to eq('1.00')
    end
  end
end
