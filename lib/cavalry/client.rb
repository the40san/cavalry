module Cavalry
  class Client
    attr_reader :errors

    def initialize(config)
      @config = config
      @errors = []

      config.load_models
      config.load_validators
    end

    def run
      @errors = all_validators.flat_map do |klass|
        klass.execute_validation
      end
      @done = true
    end

    def done?
      @done
    end

    def dump
      errors.map(&:dump)
    end

    private

    def all_validators
      @all_validators ||= ObjectSpace.each_object(::Cavalry::Validator.singleton_class).map do |k|
        next if k.singleton_class?
        next if k == ::Cavalry::Validator
        k
      end.compact
    end
  end
end
