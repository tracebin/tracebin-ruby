require 'vizsla/logger'
require 'vizsla/reporter'

module Vizsla
  class PuppetMaster
    def initialize(puppet, options = {})
      @puppet = puppet
      @logger = RequestLogger.new(options[:logger])
      @storage = ::Vizsla::Agent.storage
    end

    def process
      # @logger.display_payload @puppet.payload
      @storage << @puppet.payload
    end
  end
end
