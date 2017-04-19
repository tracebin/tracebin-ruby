require 'concurrent'

module Vizsla
  class Storage
    attr_reader :values

    def initialize
      @values = Concurrent::Array.new
      @unloaded = true
    end

    def add(payload)
      @unloaded = false
      @values << payload
    end
    alias_method :<<, :add

    def clear
      @unloaded = true
      @values.clear
    end
    alias_method :unload, :clear

    def unloaded?
      @unloaded
    end
  end
end
