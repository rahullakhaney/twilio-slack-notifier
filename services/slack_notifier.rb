require 'slack'
require 'json/ext'

class SlackNotifier
  attr_reader :client, :slack_channel, :twilio_name

  def initialize(slack_token:, channel:, twilio_name:)
    @client = Slack::Client.new token: slack_token
    @slack_channel = channel
    @twilio_name = twilio_name
  end

  def incoming_call_notification(conf_token:, web_client_link:, location:, from:)
    notification = {
                     'fallback': "Someone is calling but you can't answer it here.",
                     'color': '#36a64f',
                     'author_name': "Number: #{from}\n Location: #{location}",
                     'title': 'Click HERE to answer the call',
                     'title_link': "#{web_client_link}?conf_token=#{conf_token}"
                    }

    client.chat_postMessage(channel: slack_channel,
                            text: 'Someone is calling here!',
                            attachments: [notification].to_json) unless is_twilio_client?(from)

  end

  def answered_call_notification(from)
    client.chat_postMessage(channel: slack_channel,
                            text: 'Call answered :point_up:') if is_twilio_client?(from)
  end

  def finished_call_notification
    client.chat_postMessage(channel: slack_channel,
                            text: 'Call finished :end:')
  end

  private

  def is_twilio_client?(from)
    from == "client:#{twilio_name}"
  end
end
