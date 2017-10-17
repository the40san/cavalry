module Cavalry
  class Error
    delegate :errors, to: :@record

    def initialize(record)
      @record = record
      dump
    end

    def dump
      { record: @record.class.name }.tap do |h|
        h.merge!(attributes: @record.attributes) if @record.respond_to?(:attributes)
        h.merge!(errors: errors.to_hash)
      end
    end
  end
end
