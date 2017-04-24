require 'tracebin/logger'
require 'tracebin/reporter'

module Tracebin
  class PuppetMaster
    def initialize(puppet, options = {})
      @puppet = puppet
      @logger = RequestLogger.new(options[:logger])
      @storage = ::Tracebin::Agent.storage
    end

    def process
      # @logger.display_payload @puppet.payload
      @storage << @puppet.payload
    end
  end
end
