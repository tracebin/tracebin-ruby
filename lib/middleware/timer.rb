class Timer
  def initialize(app)
    @app = app
  end

  def call(env)
    dup.__call(env)
  end

  def __call(env)
    time_started = Time.now
    status, headers, response = @app.call(env)
    time_ended = Time.now
    Rails.logger.debug "=" * 50
    Rails.logger.debug "Request time: #{(time_ended - time_started).round(2)}s"
    Rails.logger.debug "=" * 50
    [status, headers, response]
  end
end
