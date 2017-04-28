# frozen_string_literal: true

require 'slack'
require 'json/ext'

class SlackNotifier
  attr_reader :client, :slack_channel, :twilio_name

  def initialize(slack_token:, channel:, twilio_name:)
    @client = Slack::Client.new token: slack_token
    @slack_channel = '#' + channel
    @twilio_name = twilio_name
  end

  def incoming_call_notification(conf_token:, web_client_link:, location:, from:)
    line_busy = yield if block_given?
    @from = from
    @web_client_link = web_client_link
    @location = location
    @conf_token = conf_token

    return if twilio_client?(from)

    post_incoming_call_message(line_busy: line_busy)
  end

  def answered_call_notification(from)
    return unless twilio_client?(from)

    client.chat_postMessage(channel: slack_channel,
                            text: 'Call answered :point_up:')
  end

  def finished_call_notification
    client.chat_postMessage(channel: slack_channel,
                            text: 'Call finished :end:')
  end

  def last_message_recording_notification(recording:)
    @recording = recording
    client.chat_postMessage(channel: slack_channel,
                            text: 'Last message recording is ready for you!',
                            attachments: [last_recording_notification].to_json)
  end

  private

  def post_incoming_call_message(line_busy: false)
    line_busy ? post_line_busy_message : post_line_free_message
  end

  def post_line_busy_message
    client.chat_postMessage(channel: slack_channel,
                            text: 'What a rush! Someone is calling, but the line is busy!',
                            attachments: [line_busy_notification].to_json)
  end

  def post_line_free_message
    client.chat_postMessage(channel: slack_channel,
                            text: 'Someone is calling <!here>!',
                            attachments: [line_free_notification].to_json)
  end

  def line_busy_notification
    {
      'fallback': 'Someone is calling but you can\'t answer it here.',
      'color': '#36a64f',
      'author_name': "Number: #{@from}\n Location: #{@location}",
      'title': 'You can check the recorded message later.'
    }
  end

  def line_free_notification
    {
      'fallback': 'Someone is calling but you can\'t answer it here.',
      'color': '#36a64f',
      'author_name': "Number: #{@from}\n Location: #{@location}",
      'title': 'Click HERE to answer the call',
      'title_link': "#{@web_client_link}?conf_token=#{@conf_token}"
    }
  end

  def last_recording_notification
    {
      'fallback': 'You can\'t view the message here.',
      'color': '#36a64f',
      'author_name': "Number: #{@from}\n Duration: #{@recording.duration}",
      'title': 'Click HERE to view the recording',
      'title_link': @recording.mp3
    }
  end

  def twilio_client?(from)
    from == "client:#{twilio_name}"
  end
end
