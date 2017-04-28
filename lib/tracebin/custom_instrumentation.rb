require 'tracebin/events'
require 'tracebin/helpers'

module Tracebin
  module CustomInstrumentation
    class << self
      include Tracebin::Helpers

      def instrument(identifier)
        unless block_given?
          raise ArgumentError, 'Tracebin instrumentation must receive a block'
        end

        start_time = timestamp_string
        yield
        end_time = timestamp_string

        event_data = [
          'custom.tracebin',
          start_time,
          end_time,
          {
            identifier: identifier
          }
        ]

        handle_event event_data
      end

      private

      def handle_event(event_data)
        event = Tracebin::CustomEvent.new event_data
        Tracebin::Recorder << event
      end
    end
  end

  class << self
    def instrument(*args, &block)
      Tracebin::CustomInstrumentation.instrument *args, &block
    end
  end
end
