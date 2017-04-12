module Vizsla
  module Helpers
    def to_milliseconds(time)
      Integer((time.to_f * 1000).round(0))
    end
  end
end
