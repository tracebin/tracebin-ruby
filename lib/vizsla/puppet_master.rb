require 'vizsla/logger'
require 'vizsla/reporter'

module Vizsla
  class PuppetMaster
    def initialize(puppet, options = {})
      @puppet = puppet
      @logger = RequestLogger.new(options[:logger])
      @reporter = Reporter.new
    end

    def process
      @logger.display_payload @puppet.payload
      @reporter.send_data @puppet.payload
    end
  end
end
