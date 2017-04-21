# frozen_string_literal: true

class CreateTwilioConference
  attr_reader :client, :caller

  def initialize(caller:, client:)
    @client = client
    @caller = caller
  end

  def call
    Twilio::TwiML::Response.new do |response|
      if check_line_busy
        handle_busy_line(response)
      else
        handle_open_line(response)
        yield if block_given?
      end
    end.text
  end

  private

  def handle_busy_line(response)
    response.Say 'Our line is currently busy, leave us a message or try again later'
    response.Record maxLength: 180,
                    action: '/message_recorded',
                    recordingStatusCallback: '/last_message_recording_ready'
    response.Hangup
  end

  def handle_open_line(response)
    response.Dial callerId: caller do |call|
      call.Conference 'conf',
                   startConferenceOnEnter: true,
                   maxParticipants: 2,
                   endConferenceOnExit: true,
                   record: 'record-from-start'
    end
  end

  def check_line_busy
    CheckLineBusy.new(client: client).call
  end
end
