require 'vizsla/timer'

module Vizsla
  class BackgroundTimer < ::Vizsla::Timer
    def elapsed
      "SIDEKIQ!!!" * 5 + "#{(@stop_time - @start_time).round 2}s" + "SIDEKIQ!!!" * 5
    end
  end
end
