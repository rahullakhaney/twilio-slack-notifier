# frozen_string_literal: true

class Controller < Sinatra::Base
  use AppConfig

  set :views, File.expand_path('../../views', __FILE__)

  notifier = SlackNotifier.new(slack_token: AppConfig.slack.client_token,
                               channel: AppConfig.slack.channel,
                               twilio_name: AppConfig.twilio.client_name)
  twilio_client = SetupTwilioClient.new(account_sid: AppConfig.twilio.account_sid,
                                        auth_token: AppConfig.twilio.auth_token)
                                   .call

  post '/twilio' do
    notifier.incoming_call_notification(
      conf_token: ConferenceTokenHandler.generate,
      web_client_link: AppConfig.web_client_link,
      from: customer_number,
      location: customer_location
    ) { check_line_busy(client: twilio_client) }

    CreateTwilioConference.new(caller: AppConfig.twilio.caller,
                               client: twilio_client)
                          .call { notifier.answered_call_notification(customer_number) }
  end

  get '/call' do
    raise not_found if conf_token_not_valid

    capability = SetupTwilioDevice.new(account_sid: AppConfig.twilio.account_sid,
                                       auth_token: AppConfig.twilio.auth_token,
                                       app_sid: AppConfig.twilio.app_sid,
                                       client_name: AppConfig.twilio.client_name)
                                  .call

    token = capability.generate
    erb :index, locals: { token: token }
  end

  post '/finished' do
    notifier.finished_call_notification
    200
  end

  post '/message_recorded' do
    200
  end

  post '/last_message_recording_ready' do
    recording = twilio_client.account.recordings.get(params['RecordingSid'])
    notifier.last_message_recording_notification(recording: recording)
    200
  end

  private

  def check_line_busy(client:)
    CheckLineBusy.new(client: client).call
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
end
