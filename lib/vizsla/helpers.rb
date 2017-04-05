module Vizsla
  module Helpers
    def to_milliseconds(time)
      (time.to_f * 1000).round 1
    end
  end
end
