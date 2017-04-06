require 'vizsla/logger'

module Vizsla
  class PuppetMaster
    def initialize(puppet)
      @puppet = puppet
      @logger = RequestLogger.new
    end

    def process
      if @puppet.is_a? Vizsla::Timer
        @logger.request_response_time @puppet.elapsed
        @logger.log_events @puppet.events
      elsif @puppet.is_a? Vizsla::SystemInfo
        @logger.log_system_info(@puppet.all_data)
      end
    end
  end
end
