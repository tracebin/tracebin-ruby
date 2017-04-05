require 'vizsla/recorder' unless defined?(::Vizsla::Recorder)
require 'vizsla/patches' unless defined?(::Vizsla::Patches)

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
      {
        layout: event.last[:layout]
      }
    end
  end

  class Subscribers
    def initialize
      @events_data = Recorder
      collect_events_data
    end

    def sql_hook
      return unless rails_app?
      ActiveSupport::Notifications.subscribe "sql.active_record" do |*args|
        event = SQLEvent.new(args)
        @events_data << event if event.valid?
      end
    end

    def process_action_hook
      return unless rails_app?
      ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
        event = ControllerEvent.new(args)
        @events_data << event
      end
    end

    def render_template_hook
      return unless rails_app?
      ActiveSupport::Notifications.subscribe "render_template.action_view" do |*args|
        event = ViewEvent.new(args)
        @events_data << event
      end
    end

    # ===---------------------------===
    # Non-Rails Hooks
    # ===---------------------------===

    def postgres_hook
      unless rails_app?
        ::Vizsla::Patches.patch_postgres do |event_data|
          event = SQLEvent.new event_data
          @events_data << event
        end
      end
    end

    # ===---------------------------===
    # Aux
    # ===---------------------------===

    def collect_events_data
      sql_hook
      process_action_hook
      render_template_hook
      postgres_hook
    end

    def report_events_data
      @logger.log_events(@events_data)
    end

    private

    def rails_app?
      defined? ::Rails
    end
  end
end
