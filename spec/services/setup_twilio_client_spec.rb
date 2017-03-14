require 'spec_helper'

describe SetupTwilioClient do
  let(:twilio_client) { described_class.new(account_sid: '123123', auth_token: '456456') }

  describe '.call' do
    it 'creates Twilio REST Client object' do
      expect(Twilio::REST::Client).to receive(:new)
      twilio_client.call
    end
  end
end
