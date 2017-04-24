require 'concurrent'

module Tracebin
  class Storage
    attr_reader :values

    def initialize
      @values = Concurrent::Array.new
    end

    def add(payload)
      @values << payload
    end
    alias_method :<<, :add

    def add_payload(payload)
      @values += payload if payload.is_a?(Array)
    end

    def unload
      duplicate_values = @values.dup
      @values.clear
      duplicate_values
    end

    def unloaded?
      @values.empty?
    end
  end
end
