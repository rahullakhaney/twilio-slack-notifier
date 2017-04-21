# frozen_string_literal: true

require 'spec_helper'

describe Controller do
  include Rack::Test::Methods

  before { allow_any_instance_of(SlackNotifier).to receive(:incoming_call_notification) }

  describe 'POST /twilio' do
    subject { post '/twilio' }

    it 'generates new conference token' do
      allow(ConferenceTokenHandler).to receive(:generate)
      expect(ConferenceTokenHandler).to receive(:generate)
      subject
    end

    it 'passes SetupTwilioClient service when creating Conference' do
      allow(CreateTwilioConference).to receive_message_chain(:new, :call)
      expect(CreateTwilioConference).to receive(:new)
        .with(hash_including(client: Twilio::REST::Client))
      subject
    end

    it 'invokes SlackNotifier#incoming_call_notification' do
      expect_any_instance_of(SlackNotifier).to receive(:incoming_call_notification)
      subject
    end

    it 'calls CreateTwilioConference service' do
      expect(CreateTwilioConference).to receive_message_chain(:new, :call)
      subject
    end
  end

  describe 'GET /call' do
    subject { get '/call', params }

    before { allow(ConferenceTokenHandler).to receive(:current_token) { 'ABC' } }

    context 'when no token passed' do
      let(:params) { { 'conf_token' => nil } }

      it 'returns 404' do
        subject
        expect(last_response.status).to be 404
      end
    end

    context 'when wrong token passed' do
      let(:params) { { 'conf_token' => 'ABs' } }

      it 'returns 404' do
        subject
        expect(last_response.status).to be 404
      end
    end

    context 'when proper token passed' do
      let(:params) { { 'conf_token' => 'ABC' } }
      let(:capability) { double }

      before do
        allow(SetupTwilioDevice).to receive_message_chain(:new, :call) { capability }
        allow(capability).to receive(:generate) { 'asd' }
      end

      it 'returns 200 status' do
        subject
        expect(last_response.status).to be 200
      end

      it 'calls SetupTwilioDevice service' do
        expect(SetupTwilioDevice).to receive_message_chain(:new, :call)
        subject
      end

      it 'generates device token' do
        expect(capability).to receive(:generate)
        subject
      end
    end
  end

  describe 'POST /finished' do
    subject { post '/finished' }
    before { allow_any_instance_of(SlackNotifier).to receive(:finished_call_notification) }

    it 'invokes SlackNotifier#finished_call_notification' do
      expect_any_instance_of(SlackNotifier).to receive(:finished_call_notification)
      subject
    end

    it 'returns 200' do
      subject
      expect(last_response.status).to be 200
    end
  end

  describe 'POST /message_recorded' do
    it 'returns 201' do
      post '/message_recorded'
      expect(last_response.status).to be 201
    end
  end

  describe 'POST /last_message_recording_ready' do
    before { allow_any_instance_of(Twilio::REST::Recording).to receive(:duration) }

    subject { post '/last_message_recording_ready' }

    it 'returns 201' do
      subject
      expect(last_response.status).to be 201
    end
    it 'sends the Slack notification' do
      expect_any_instance_of(SlackNotifier).to receive(:last_message_recording_notification)
      subject
    end
  end
end
