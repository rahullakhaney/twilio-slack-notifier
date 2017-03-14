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
    response.Say 'Our line is currently busy, please try again later'
    response.Hangup
  end

  def handle_open_line(response)
    response.Dial callerId: caller do |call|
      call.Conference 'conf',
                   startConferenceOnEnter: true,
                   maxParticipants: 2,
                   endConferenceOnExit: true,
                   record: "record-from-start"
    end
  end

  def check_line_busy
    conferences = client.account.conferences
    in_progress_conference = conferences.list(status: 'in-progress').first
    in_progress_conference.participants.list.count == 2 if in_progress_conference
  end
end
