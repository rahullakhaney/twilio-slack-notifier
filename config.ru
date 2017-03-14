$root = ::File.dirname(__FILE__)
require ::File.join( $root, 'twilio-slack-notifier' )
run TwilioSlackNotifier
