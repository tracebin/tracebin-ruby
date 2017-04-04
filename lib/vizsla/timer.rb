module Vizsla
  class Timer
    def initialize
      @start_time = nil
      @stop_time = nil
    end

    def start!
      @start_time = Time.now
    end

    def stop!
      @stop_time = Time.now
    end

    def elapsed
      "#{(@stop_time - @start_time).round 2}s"
    end
  end
end
