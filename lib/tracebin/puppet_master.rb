require 'tracebin/logger'
require 'tracebin/reporter'

module Tracebin
  class PuppetMaster
    def initialize(puppet, options = {})
      @puppet = puppet
      @storage = ::Tracebin::Agent.storage
    end

    def process
      @storage << @puppet.payload
    end
  end
end
