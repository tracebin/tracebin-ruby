require 'vizsla/recorder'

module Vizsla
  class Timer
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
      @events = Recorder.events
      Recorder.stop_recording
      @stop_time = Time.now
    end

    def elapsed
      "#{(@stop_time - @start_time).round 2}s"
    end
  end
end
