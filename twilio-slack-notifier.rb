# frozen_string_literal: true

require 'sinatra/base'
require 'twilio-ruby'

Dir[::File.dirname(__FILE__) + '/services/*.rb'].each { |file| require file }
Dir[::File.dirname(__FILE__) + '/config/*.rb'].each { |file| require file }
Dir[::File.dirname(__FILE__) + '/controllers/*.rb'].each { |file| require file }

class TwilioSlackNotifier < Sinatra::Base
  use Controller
  set :server, :thin
end
