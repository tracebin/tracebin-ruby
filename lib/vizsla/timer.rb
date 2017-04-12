require 'vizsla/recorder'
require 'vizsla/helpers'


module Vizsla
  class Timer
    include ::Vizsla::Helpers

    attr_reader :events, :transaction_name

    def initialize(transaction_name = nil)
      @transaction_name = transaction_name
      @start_time = nil
      @stop_time = nil
    end

    def start!
      @start_time = Time.now
      Recorder.start_recording
    end

    def stop!
      collect_events
      Recorder.stop_recording
      @stop_time = Time.now
    end

    def payload
      {
        type: transaction_type,
        name: @transaction_name,

        start: @start_time,
        stop: @stop_time,
        elapsed: elapsed,

        data: @events
      }
    end

    def elapsed
      to_milliseconds @stop_time - @start_time
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
