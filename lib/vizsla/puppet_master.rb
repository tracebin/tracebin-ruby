require 'vizsla/logger'

module Vizsla
  class PuppetMaster
    def initialize(timer)
      @timer = timer
      @logger = RequestLogger.new
    end

    def process
      @logger.request_response_time @timer.elapsed
      @logger.log_events @timer.events
    end
  end
end
