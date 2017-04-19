require 'concurrent'

module Vizsla
  class Storage
    attr_reader :values

    def initialize
      @values = Concurrent::Array.new
    end

    def add(payload)
      @values << payload
    end
    alias_method :<<, :add

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
