# frozen_string_literal: true

class SetupTwilioDevice
  attr_reader :account_sid, :token, :app_sid, :client_name

  def initialize(account_sid:, auth_token:, app_sid:, client_name:)
    @account_sid = account_sid
    @token = auth_token
    @app_sid = app_sid
    @client_name = client_name
  end

  def call
    device = Twilio::Util::Capability.new account_sid, token
    device.allow_client_outgoing app_sid
    device.allow_client_incoming client_name
    device
  end
end
