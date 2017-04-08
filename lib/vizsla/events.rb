module Vizsla
  class Event
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

    def prettify_data
      {
        event_started: event[1],
        event_ended: event[2],
        event_duration: event[2] - event[1],
        event_payload: prettify_payload
      }
    end
  end

  class SQLEvent < Event
    def valid?
      event.last[:name] != "SCHEMA"
    end

    private

    def prettify_payload
      {
        query: event.last[:sql]
      }
    end
  end

  class ControllerEvent < Event
    private

    def prettify_payload
      payload = event.last
      {
        format: payload[:format],
        controller: payload[:controller],
        action: payload[:action],
        path: payload[:path],
        db_runtime: payload[:db_runtime]
      }
    end
  end

  class ViewEvent < Event
    private

    def prettify_payload
      payload = event.last

      {
        template_file: payload[:identifier]
        layout: payload[:layout]
      }
    end
  end

  class SinatraEvent < Event
    private

    def prettify_payload
      {
        route: event.last
      }
    end
  end
end
