require 'tracebin/recorder'
require 'tracebin/patches'
require 'tracebin/events'
require 'tracebin/background_job_instrumentation'

module Tracebin
  ##
  # Subscribes to certain events, handels them, and passes event data to the
  # +Recorder+ class. The general workflow goes like this:
  #
  # 1. Patch the method you want to profile. It should generate an array that
  # looks like the following:
  #
  #   [
  #     "event_type.event_domain",
  #     start_time,
  #     stop_time,
  #     etc...,
  #     { event: :data }
  #   ]
  #
  # Note that the event hash must be the last element in the array (this is to
  # maintain consistency with ActiveSupport::Notifications).
  #
  # 2. Store that event array into an appropriate +Event+ subclass.
  # 3. Add each +Event+ object to +@events_data+ using the +#<<+ method.
  #
  class Subscribers
    def initialize
      @events_data = Recorder
      collect_events_data
    end

    private

    def collect_events_data
      if rails_app?
        rails_hooks
      else
        other_hooks
      end

      background_job_hooks
    end

    def rails_hooks
      sql_hook
      process_action_hook
      render_layout_hook
      render_template_hook
      render_partial_hook
    end

    def other_hooks
      sinatra_hook if sinatra_app?
      db_hooks
      background_job_hooks
    end

    def background_job_hooks
      if defined? ::ActiveJob
        active_job_hook
      else
        sidekiq_hook
        resque_hook
      end
    end

    def db_hooks
      postgres_hook
      mysql2_hook
    end

    # ===---------------------------===
    # Rails Hooks
    # ===---------------------------===

    def sql_hook
      subscribe_asn 'sql.active_record', SQLEvent
    end

    def process_action_hook
      subscribe_asn 'process_action.action_controller', ControllerEvent
    end

    def render_layout_hook
      unless [ActionPack::VERSION::MAJOR, ActionPack::VERSION::MINOR] == [3, 0]
        ::Tracebin::Patches.patch_action_view_layout do |event_data|
          event = ViewEvent.new event_data
          @events_data << event
        end
      end
    end

    def render_template_hook
      subscribe_asn 'render_template.action_view', ViewEvent
    end

    def render_partial_hook
      subscribe_asn 'render_partial.action_view', ViewEvent
    end

    def active_job_hook
      ::Tracebin::BackgroundJobInstrumentation.install :active_job
    end

    # ===---------------------------===
    # DB Hooks
    # ===---------------------------===

    def postgres_hook
      return unless defined? ::PG
      ::Tracebin::Patches.patch_postgres do |event_data|
        event = SQLEvent.new event_data
        @events_data << event
      end
    end


    def mysql2_hook
      return unless defined? ::Mysql2
      ::Tracebin::Patches.patch_mysql2 do |event_data|
        event = SQLEvent.new event_data
        @events_data << event
      end
    end

    # ===---------------------------===
    # Background Job Hooks
    # ===---------------------------===

    def sidekiq_hook
      return unless defined? ::Sidekiq
      ::Tracebin::BackgroundJobInstrumentation.install :sidekiq
    end

    def resque_hook
      return unless defined? ::Resque
      ::Tracebin::BackgroundJobInstrumentation.install :resque
    end

    # ===---------------------------===
    # Sinatra Hooks
    # ===---------------------------===

    def sinatra_hook
      ::Tracebin::Patches.patch_sinatra do |event_data|
        event = SinatraEvent.new event_data
        @events_data << event
      end
    end

    # ===---------------------------===
    # Aux
    # ===---------------------------===

    def subscribe_asn(event_name, event_klass)
      ActiveSupport::Notifications.subscribe event_name do |*args|
        event = event_klass.new args
        @events_data << event if event.valid?
      end
    end

    def rails_app?
      defined? ::Rails
    end

    def sinatra_app?
      defined? ::Sinatra
    end
  end
end
