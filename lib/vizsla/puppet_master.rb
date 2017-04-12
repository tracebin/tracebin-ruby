require 'vizsla/logger'

module Vizsla
  class PuppetMaster
    def initialize(puppet, options = {})
      @puppet = puppet
      @logger = RequestLogger.new(options[:logger])
    end

    def process
      @logger.display_payload @puppet.payload
    end
  end
end
