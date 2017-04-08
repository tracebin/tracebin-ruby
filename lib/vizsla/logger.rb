module Vizsla
  class RequestLogger
    def initialize(logger_override = nil)
      @logger_override = logger_override
    end

    def transaction_time(query_time)
      log "=" * 50
      log "Total transaction time: #{query_time} seconds."
      log "=" * 50
    end

    def log_events(events)
      unless events.empty?
        events.keys.each do |event_name|
          log "=" * 50
          log events[event_name]
          log "=" * 50
        end
      end
    end

    def log_system_info(system_data)
      system_data.keys.each do |category|
        log "=" * 50
        log "Category: #{category}, value: #{system_data[category]}"
        log "=" * 50
      end
    end

    private

    def rails_app?
      defined? ::Rails
    end

    def log(text)
      if !@logger_override.nil?
        @logger_override.info text
      elsif rails_app?
        Rails.logger.debug text
      else
        puts text
      end
    end
  end
end
