module Vizsla
  class RequestLogger
    def request_response_time(query_time)
      Rails.logger.debug "=" * 50
      Rails.logger.debug "Total request/response time: #{query_time} seconds."
      Rails.logger.debug "=" * 50
    end

    def log_events(events)
      if events.empty?
        Rails.logger.debug "=" * 50
        Rails.logger.debug "No data collected. Are you calling ActiveRecord at all?"
        Rails.logger.debug "=" * 50
      else
        events.keys.each do |event_name|
          Rails.logger.debug "=" * 50
          Rails.logger.debug events[event_name]
          Rails.logger.debug "=" * 50
        end
      end
    end
  end
end
