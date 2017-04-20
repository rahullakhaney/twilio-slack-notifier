# frozen_string_literal: true

describe CheckLineBusy do
  let(:client) { double('client') }
  let(:conference) { double('conference') }

  describe '#call' do
    before do
      allow(client)
        .to receive_message_chain(:account, :conferences, :list, :first)
        .and_return conference
    end

    it 'returns false if the line is free' do
      allow(conference)
        .to receive_message_chain(:participants, :list, :count)
        .and_return 1

      expect(described_class.new(client: client).call).to be_falsy
    end

    it 'returns true if the line is busy' do
      allow(conference)
        .to receive_message_chain(:participants, :list, :count)
        .and_return 2

      expect(described_class.new(client: client).call).to be_truthy
    end
  end
end
