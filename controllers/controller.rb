# frozen_string_literal: true

class Controller < Sinatra::Base
  set :views, File.expand_path('../../views', __FILE__)

  post '/twilio' do
    send_incoming_call_notification
    create_twilio_conference
  end

  get '/call' do
    raise not_found if conf_token_not_valid
    setup_twilio_device
    generate_token
    erb :index, locals: { token: @token }
  end

  post '/finished' do
    notifier.finished_call_notification
    200
  end

  post '/message_recorded' do
    201
  end

  post '/last_message_recording_ready' do
    recording = twilio_account.recordings.get(params['RecordingSid'])
    notifier.last_message_recording_notification(recording: recording)
    201
  end

  private

  def config
    parsed_file = ERB.new(File.read('config/config.yml')).result
    @config ||= AppConfig.new(YAML.safe_load(parsed_file))
  end

  def notifier
    @notifier ||= SlackNotifier.new(slack_token: config.slack.client_token,
                                    channel: config.slack.channel,
                                    twilio_name: config.twilio.client_name)
  end

  def twilio_client
    @twilio_client ||= SetupTwilioClient.new(account_sid: config.twilio.account_sid,
                                             auth_token: config.twilio.auth_token)
                                        .call
  end

  def send_incoming_call_notification
    notifier.incoming_call_notification(
      conf_token: ConferenceTokenHandler.generate,
      web_client_link: config.web_client_link,
      from: customer_number,
      location: customer_location
    ) { check_line_busy(client: twilio_client) }
  end

  def create_twilio_conference
    CreateTwilioConference.new(caller: config.twilio.caller,
                               client: twilio_client)
                          .call { notifier.answered_call_notification(customer_number) }
  end

  def setup_twilio_device
    @capability = SetupTwilioDevice.new(account_sid: config.twilio.account_sid,
                                       auth_token: config.twilio.auth_token,
                                       app_sid: config.twilio.app_sid,
                                       client_name: config.twilio.client_name)
                                   .call
  end

  def check_line_busy(client:)
    CheckLineBusy.new(client: client).call
  end

  def generate_token
    @token = @capability.generate
  end

  def conf_token_not_valid
    correct_token = ConferenceTokenHandler.current_token
    params['conf_token'].nil? || params['conf_token'] != correct_token
  end

  def customer_number
    from = params['From']
    from.nil? || from.empty? ? 'Unknown' : params['From']
  end

  def customer_location
    location = params['FromCity']
    location.nil? || location.empty? ? 'Unknown' : params['FromCity']
  end

  def twilio_account
    twilio_client.account
  end
end
