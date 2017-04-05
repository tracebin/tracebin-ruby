require 'vizsla/recorder' unless defined?(::Vizsla::Recorder)

module Vizsla
  class Subscribers
    def initialize
      @events_data = Recorder
      # @logger = RequestLogger.new
      collect_events_data
    end

    def sql_hook
      ActiveSupport::Notifications.subscribe "sql.active_record" do |*args|
        sql_data = args.extract_options!
        @events_data << sql_data[:sql] unless sql_data[:name] == "SCHEMA"
      end
    end

    def process_action_hook
      ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
        controller_data = args.extract_options!
        @events_data << {
          responded_controller: controller_data[:controller],
          requested_path: controller_data[:path]
        }
      end
    end

    def render_template_hook
      ActiveSupport::Notifications.subscribe "render_template.action_view" do |*args|
        template_data = args.extract_options!
        @events_data << { rendered_layout: template_data[:layout] }
      end
    end

    def collect_events_data
      sql_hook
      process_action_hook
      render_template_hook
    end

    def report_events_data
      @logger.log_events(@events_data)
    end
  end
end
