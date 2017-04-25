# frozen_string_literal: true

require 'yaml'

class AppConfig
  def initialize(hash)
    @config = hash
  end

  def method_missing(name, *args)
    if @config.is_a?(Hash) && @config.key?(name.to_s)
      node = @config[name.to_s]
      define_singleton_method(name) do
        return node if node.is_a?(String)
        AppConfig.new(node)
      end
      send(name.to_sym)
    else
      super
    end
  end

  def respond_to_missing?(name, include_private = false)
    @file.to_s.match(/"#{name.to_s}"/) || super
  end
end
