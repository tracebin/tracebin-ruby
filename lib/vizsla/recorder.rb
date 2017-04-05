module Vizsla
  class Recorder
    THREAD_LOCAL_KEY = :_vizsla_current
    LOCK = Mutex.new

    class << self
      def current
        Thread.current[THREAD_LOCAL_KEY]
      end

      def current=(val)
        Thread.current[THREAD_LOCAL_KEY] = val
      end

      def start_recording
        self.current = []
      end

      def recording?
        !self.current.nil?
      end

      def add_event(event)
        return unless self.recording?
        self.current << event
      end

      def events
        self.current
      end

      def stop_recording
        Thread.current[THREAD_LOCAL_KEY] = nil
      end
    end
  end
end
