require 'vizsla/timer'

module Vizsla
  class BackgroundTimer < ::Vizsla::Timer
    def transaction_type
      'background_job'
    end
  end
end
