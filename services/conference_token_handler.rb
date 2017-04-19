# frozen_string_literal: true

require 'securerandom'

class ConferenceTokenHandler
  def self.generate
    @token = SecureRandom.hex(20)
  end

  def self.current_token
    @token
  end
end
