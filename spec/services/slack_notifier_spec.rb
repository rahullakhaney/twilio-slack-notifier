# frozen_string_literal: true

require 'spec_helper'

describe SlackNotifier do
  let(:notifier) do
    described_class.new(channel: '#channel', twilio_name: 'twilio', slack_token: 'ABC123')
  end

  let(:slack_client) { double('slack_client') }

  subject { notifier }

  before { allow(Slack::Client).to receive(:new).and_return slack_client }

  it 'instantiates Slack Client on initialize' do
    expect(Slack::Client).to receive(:new)
    subject
  end

  describe '#incoming_call_notification' do
    before { allow_any_instance_of(Slack::Client).to receive(:incoming_call_notification) }

    context 'when all params are correct' do
      it 'sends the message' do
        expect(slack_client).to receive(:chat_postMessage)
        subject.incoming_call_notification(conf_token: 'token',
                                           web_client_link: 'netguru.co',
                                           location: 'Poznan',
                                           from: '+4832153451')
      end
    end

    context 'when conf_token is missing' do
      it 'raises error' do
        expect do
          subject.incoming_call_notification(web_client_link: 'netguru.co',
                                             location: 'Poznan',
                                             from: '+4832153451')
        end.to raise_error(ArgumentError)
      end
    end

    context 'when web_client_link is missing' do
      it 'raises error' do
        expect do
          subject.incoming_call_notification(conf_token: 'token',
                                             location: 'Poznan',
                                             from: '+4832153451')
        end.to raise_error(ArgumentError)
      end
    end

    context 'when location is missing' do
      it 'raises error' do
        expect do
          subject.incoming_call_notification(conf_token: 'token',
                                             web_client_link: 'netguru.co',
                                             from: '+4832153451')
        end.to raise_error(ArgumentError)
      end
    end

    context 'when from is missing' do
      it 'raises error' do
        expect do
          subject.incoming_call_notification(conf_token: 'token',
                                             web_client_link: 'netguru.co',
                                             location: 'Poznan')
        end.to raise_error(ArgumentError)
      end
    end
  end

  describe '#answered_call_notification' do
    context 'when client is known' do
      it 'sends the message' do
        allow_any_instance_of(Slack::Client).to receive(:answered_call_notification)
        expect(slack_client).to receive(:chat_postMessage)
        subject.answered_call_notification('client:twilio')
      end
    end

    context 'when client is unknown' do
      it 'does NOT send the message' do
        allow_any_instance_of(Slack::Client).to receive(:answered_call_notification)
        expect(slack_client).not_to receive(:chat_postMessage)
        subject.answered_call_notification('unknown')
      end
    end

    context 'when from is missing' do
      it 'raises error' do
        expect { subject.answered_call_notification }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#finished_call_notification' do
    it 'sends the message' do
      allow_any_instance_of(Slack::Client).to receive(:finished_call_notification)
      expect(slack_client).to receive(:chat_postMessage)
      subject.finished_call_notification
    end
  end
end
