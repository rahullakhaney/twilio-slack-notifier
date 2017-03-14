require 'spec_helper'

describe ConferenceTokenHandler do
  describe '.generate' do
    let(:token) { SecureRandom.hex(20) }

    it 'generates conference token' do
      allow(described_class).to receive(:generate).and_return token
      expect(described_class.generate).to eq token
    end
  end

  describe '.get_current_token' do
    let!(:generated_token) { described_class.generate }

    it 'gets proper current token' do
      expect(described_class.get_current_token).to eq generated_token
    end
  end
end
