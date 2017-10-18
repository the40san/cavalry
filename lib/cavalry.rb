require "cavalry/version"
require "active_support"
require "active_model"

module Cavalry
  autoload :Config, 'cavalry/config'
  autoload :Client, 'cavalry/client'
  autoload :Validator, 'cavalry/validator'
  autoload :Error, 'cavalry/error'

  class DSLError < RuntimeError; end

  class << self
    def configure
      yield config
    end

    delegate :run, :errors, :dump, to: :client

    def valid?
      run unless client.done?
      errors.blank?
    end


    private

    def client
      @client ||= Client.new(config)
    end

    def config
      @config ||= Config.new
    end
  end
end
