ENV['RACK_ENV'] = 'test'

require File.expand_path('../../twilio-slack-notifier.rb', __FILE__)
require 'rspec'
require 'rack/test'

def app
  TwilioSlackNotifier
end
