require 'vizsla/logger'

module Vizsla
  class PuppetMaster
    def initialize(puppet, options = {})
      @puppet = puppet
      @logger = RequestLogger.new(options[:logger])
    end

    def process
      if @puppet.is_a? Vizsla::Timer
        @logger.transaction_time @puppet.elapsed
        @logger.log_events @puppet.events
      elsif @puppet.is_a? Vizsla::SystemInfo
        @logger.log_system_info(@puppet.all_data)
      end
    end
  end
end
