# frozen_string_literal: true

require 'yaml'

class AppConfig < Sinatra::Base
  @file = YAML.safe_load(File.read('config/config.yml'))
  @config = OpenStruct.new(@file)

  def self.method_missing(name)
    define_singleton_method(name) do
      if @config[name.to_s].is_a?(Hash)
        OpenStruct.new(@config[name.to_s])
      else
        @config[name.to_s]
      end
    end
    send(name.to_sym)
  end

  def self.respond_to_missing?(name, include_private = false)
    @file.to_s.match(/"%{name.to_s}"/) || super
  end
end
