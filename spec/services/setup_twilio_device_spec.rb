# frozen_string_literal: true

require 'spec_helper'

describe SetupTwilioDevice do
  account_sid = '123123'
  token = '456456'
  let(:twilio_device) do
    described_class.new(account_sid: account_sid,
                        auth_token: token,
                        app_sid: 'AP12345',
                        client_name: 'client')
  end

  describe '#call' do
    it 'creates Twilio Util Capability object' do
      device = double('twilio_device')
      allow(Twilio::Util::Capability).to receive(:new) { device }
      allow(device).to receive(:allow_client_outgoing)
      allow(device).to receive(:allow_client_incoming)
      expect(Twilio::Util::Capability).to receive(:new)
      twilio_device.call
    end
  end
end
