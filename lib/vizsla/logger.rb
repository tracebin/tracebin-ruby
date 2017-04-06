module Vizsla
  class RequestLogger
    def request_response_time(query_time)
      log "=" * 50
      log "Total request/response time: #{query_time} seconds."
      log "=" * 50
    end

    def log_events(events)
      if events.empty?
        log "=" * 50
        log "No data collected. Are you calling ActiveRecord at all?"
        log "=" * 50
      else
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
      if rails_app?
        Rails.logger.debug text
      else
        puts text
      end
    end
  end
end
