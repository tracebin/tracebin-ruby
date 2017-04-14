require 'vizsla/helpers'

module Vizsla
  class Event
    include Vizsla::Helpers

    attr_reader :event

    def initialize(event)
      @event = event
    end

    def recorder_type
      event[0]
    end

    def valid?
      true
    end

    def data_hash
      {
        event_type: type,
        start: event[1],
        stop: event[2],
        duration: to_milliseconds(event[2] - event[1]),
        data: event.last
      }
    end
  end

  class SQLEvent < Event
    def valid?
      event.last[:name] != "SCHEMA"
    end

    private

    def type
      :sql
    end
  end

  class ControllerEvent < Event
    private

    def type
      :controller_action
    end
  end

  class ViewEvent < Event
    private

    def type
      :view
    end
  end

  class SinatraEvent < Event
    private

    def type
      :route
    end
  end
end
