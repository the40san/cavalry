module Cavalry
  class Validator
    class EachValidator
      attr_reader :source_class

      def initialize(klass, &block)
        @source_class = klass
        @source_class.class_eval(&block)
      end

      def validate
        source_class.all.flat_map {|record| validate_record(record) }.compact
      end

      private

      def validate_record(record)
        return if record.valid?
        record
      end
    end
  end
end
