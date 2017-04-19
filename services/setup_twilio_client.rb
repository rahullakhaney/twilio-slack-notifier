# frozen_string_literal: true

class SetupTwilioClient
  attr_reader :account_sid, :auth_token

  def initialize(account_sid:, auth_token:)
    @account_sid = account_sid
    @auth_token = auth_token
  end

  def call
    Twilio::REST::Client.new account_sid, auth_token
  end
end
