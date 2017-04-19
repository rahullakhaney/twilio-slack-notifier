# frozen_string_literal: true

require 'spec_helper'

describe CreateTwilioConference do
  caller = '4832123123'
  let(:client) { double }
  let(:twilio_conference) { described_class.new(caller: caller, client: client) }

  subject { twilio_conference.call }

  describe '#call' do
    context 'when line is busy' do
      before { allow(twilio_conference).to receive(:check_line_busy).and_return true }

      it 'actually checks if the line is busy' do
        expect(twilio_conference).to receive(:check_line_busy)
        subject
      end

      it 'returns proper XML(TwiML) document' do
        expect(subject).to match(/<?xml version=\"1.0\" encoding=\"UTF-8\"\?>/)
      end

      it 'creates TwiML Response object' do
        allow(Twilio::TwiML::Response).to receive_message_chain(:new, :text)
        expect(Twilio::TwiML::Response).to receive(:new)
        subject
      end

      it 'says the message if the line is busy' do
        expect(subject).to match(/Our line is currently busy, please try again later/)
      end

      it 'does not start the conference' do
        expect(subject).not_to match(/Conference/)
      end
    end

    context 'when the line is not busy' do
      before { allow(twilio_conference).to receive(:check_line_busy).and_return false }

      it 'returns proper XML(TwiML) document' do
        expect(subject).to match(/xml version/)
      end

      it 'creates TwiML Response object' do
        allow(Twilio::TwiML::Response).to receive_message_chain(:new, :text)
        expect(Twilio::TwiML::Response).to receive(:new)
        subject
      end

      it 'creates the conference' do
        expect(subject).to match(/Conference/)
      end

      it 'sets the proper caller id' do
        expect(subject).to match Regexp.new(caller)
      end

      it 'records the conference' do
        expect(subject).to match(/record-from-start/)
      end
    end
  end
end
