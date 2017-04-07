require 'vizsla/recorder'
require 'vizsla/patches'
require 'vizsla/events'
require 'vizsla/background_job_instrumentation'

module Vizsla
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
      return if rails_app?
      ::Vizsla::Patches.patch_postgres do |event_data|
        event = SQLEvent.new event_data
        @events_data << event
      end
    end

    def sidekiq_hook
      return unless defined? ::Sidekiq
      ::Vizsla::BackgroundJobInstrumentation.install :sidekiq
    end

    # ===---------------------------===
    # Sinatra Hooks
    # ===---------------------------===

    def sinatra_hook
      return unless sinatra_app?
      ::Vizsla::Patches.patch_sinatra do |event_data|
        event = SinatraEvent.new event_data
        @events_data << event
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
      sinatra_hook
      sidekiq_hook
    end

    private

    def rails_app?
      defined? ::Rails
    end

    def sinatra_app?
      defined? ::Sinatra
    end
  end
end
