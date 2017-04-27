require 'tracebin/recorder'
require 'tracebin/helpers'

module Tracebin
  ##
  # This is the timer for a top-level transaction. Transactions include
  # request/response cycles, as well as background jobs. Background jobs
  # subclass this class and overwrite the +#transaction_type+ method.
  class Timer
    include ::Tracebin::Helpers

    attr_accessor :transaction_name
    attr_reader :events

    def initialize(transaction_name = nil)
      @transaction_name = transaction_name
      @start_time = nil
      @stop_time = nil
    end

    def start!
      @start_time = timestamp_string
      Recorder.start_recording
    end

    def stop!
      collect_events
      Recorder.stop_recording
      @stop_time = timestamp_string
    end

    def payload
      {
        type: :cycle_transaction,

        data: {
          transaction_type: transaction_type,
          name: @transaction_name,

          start: @start_time,
          stop: @stop_time,
          duration: duration,

          events: @events
        }
      }
    end

    def duration
      milliseconds_between @stop_time, @start_time
    end

    def transaction_type
      'request_response'
    end

    private

    def collect_events
      @events = Recorder.events
    end
  end
end
