# frozen_string_literal: true

require 'yaml'

class AppConfig < Sinatra::Base
  @config = OpenStruct.new(YAML.safe_load(File.read('config/config.yml')))

  def self.method_missing(name)
    if @config[name.to_s].is_a?(Hash)
      OpenStruct.new(@config[name.to_s])
    else
      @config[name.to_s]
    end
  end
end
