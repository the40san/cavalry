module Cavalry
  class Validator
    class EachValidator
      attr_reader :source_class

      def initialize(klass, &block)
        @source_class = klass
        @source_class.class_eval(&block)
      end

      def validate
        install_force_check_belongs_to_association if Cavalry.config.force_check_belongs_to_association && @source_class.respond_to?(:reflections)
        source_class.all.flat_map {|record| validate_record(record) }.compact
      end

      private

      def validate_record(record)
        return if record.valid?
        record
      end

      def install_force_check_belongs_to_association
        return unless defined?(ActiveRecord::Reflection::BelongsToReflection)

        @source_class.class_eval do
          reflections.values.select { |r| r.is_a?(ActiveRecord::Reflection::BelongsToReflection) }.each do |r|
            validates r.name, presence: true
          end
        end
      end
    end
  end
end
