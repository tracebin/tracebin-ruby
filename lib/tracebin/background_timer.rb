require 'tracebin/timer'

module Tracebin
  class BackgroundTimer < ::Tracebin::Timer
    def transaction_type
      'background_job'
    end
  end
end
