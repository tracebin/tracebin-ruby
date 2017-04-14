module Vizsla
  class Recorder
    THREAD_LOCAL_KEY = :_vizsla_current
    LOCK = Mutex.new

    class << self
      def current
        LOCK.synchronize do
          Thread.current[THREAD_LOCAL_KEY]
        end
      end

      def current=(val)
        Thread.current[THREAD_LOCAL_KEY] = val
      end

      def start_recording
        self.current = {}
      end

      def recording?
        !self.current.nil?
      end

      def add_event(event)
        return unless self.recording?
        self.current[:events] ||= []
        self.current[:events] << event.data_hash
      end
      alias_method :<<, :add_event

      def events
        self.current[:events]
      end

      def stop_recording
        LOCK.synchronize do
          Thread.current[THREAD_LOCAL_KEY] = nil
        end
      end
    end
  end
end
