module Cavalry
  class Validator
    class GroupValidator
      attr_reader :source_class
      attr_reader :definitions

      def initialize(klass, &block)
        @source_class = klass
        @definitions = block
      end

      def validate
        validator_context = create_validations
        validator_context.instance.validate
        validator_context.instance.errors.any? ? validator_context.instance : nil
      end

      private

      def create_validations
        new_class = Class.new
        new_class.include(GroupValidations)
        new_class.source_class = source_class
        new_class.class_eval(&@definitions)
        new_class
      end
    end

    module GroupValidations
      extend ActiveSupport::Concern

      included do
        cattr_accessor :source_class
        cattr_accessor :validators
      end

      class_methods do
        def name
          "GroupValidation"
        end

        def validate(*args, &block)
          self.validators ||= []

          if args.count.zero?
            InlineValidator.new(source_class, instance, &block).tap do |validator|
              self.validators << validator
            end
          else
            args.each do |method_name|
              self.validators << MethodCallValidator.new(source_class, instance, method_name)
            end
          end
        end

        def instance
          @instance ||= new
        end
      end

      def validate
        self.validators.map(&:validate)
      end

      def errors
        @errors ||= ActiveModel::Errors.new(self)
      end
    end

    class MethodCallValidator
      def initialize(source_class, context, method_name)
        @source_class = source_class
        @context = context
        @method_name = method_name
      end

      def validate
        if @context.method(@method_name).arity.zero?
          @context.send(@method_name)
        else
          @context.send(@method_name, @source_class.all)
        end
      end
    end

    class InlineValidator
      def initialize(source, context, &block)
        @source = source
        @context = context
        @definition = block
      end

      # execute
      def validate
        fail(DSLError, "Give me a definition") unless @definition

        tap do
          @context.class.send(:define_method, :cavalry_validation, @definition)
          @context.send(:cavalry_validation, @source.respond_to?(:all) ? @source.all : @source)
          @context.class.send(:undef_method, :cavalry_validation)
        end
      end

      # Modify the validation source when method is chained.
      # if you pass a block to method, block will be stored as validation definition.
      def method_missing(method_name, *arg, &block)
        if @source.respond_to?(method_name)
          @source = @source.send(method_name, *arg)
        else
          fail DSLError, "Method #{method_name} is missing for #{@source.inspect}"
        end

        @definition = block if block_given?
      end
    end
  end
end
