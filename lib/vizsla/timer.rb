require 'vizsla/recorder'
require 'vizsla/helpers'


module Vizsla
  class Timer
    include ::Vizsla::Helpers

    attr_reader :events

    def initialize
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

    def collect_events
      @events = Recorder.events
    end

    def elapsed
      to_milliseconds @stop_time - @start_time
    end
  end
end
