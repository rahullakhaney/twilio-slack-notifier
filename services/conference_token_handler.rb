require 'securerandom'

class ConferenceTokenHandler
  def self.generate
    @token = SecureRandom.hex(20)
  end

  def self.get_current_token
    @token
  end
end
