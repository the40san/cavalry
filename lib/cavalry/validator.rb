module Cavalry
  class Validator
    autoload :EachValidator, 'cavalry/validator/each_validator'
    autoload :GroupValidator, 'cavalry/validator/group_validator'

    class << self
      def validate_for(*klasses)
        @klasses = klasses.map { |k| append_required_module(k) }
        @each_validators = []
        @group_validators = []

        allocate_each_validators
      end

      def validate_each(&block)
        @each_validators.each {|v| v.append(&block) }
      end

      def validate_group(&block)
        @group_validators += @klasses.map {|k| GroupValidator.new(k, &block) }
      end

      def execute_validation
        error_records = [].tap do |res|
          res << @each_validators.map(&:validate).compact
          res << @group_validators.map(&:validate).compact
        end.flatten

        error_records.map {|e| Error.new(e) }
      end

      private

      def append_required_module(klass)
        unless klass.include?(ActiveModel::Validations)
          klass.include(ActiveModel::Validations)
        end
        klass
      end

      def allocate_each_validators
        @each_validators += @klasses.map {|k| EachValidator.new(k) }
      end
    end
  end
end
