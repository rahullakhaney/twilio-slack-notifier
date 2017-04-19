# frozen_string_literal: true

root_path = ::File.dirname(__FILE__)
require ::File.join(root_path, 'twilio-slack-notifier')
run TwilioSlackNotifier
