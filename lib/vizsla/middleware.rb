module Vizsla
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      dup.__call(env)
    end

    def __call(env)
      timer = Timer.new
      timer.start!

      status, headers, response = @app.call(env)

      timer.stop!

      Rails.logger.debug "=" * 50
      Rails.logger.debug "Request time: #{timer.elapsed}"
      Rails.logger.debug "=" * 50

      Rails.logger.debug '=' * 50
      Rails.logger.debug "Events: #{timer.events}"
      Rails.logger.debug '=' * 50
      [status, headers, response]
    end
  end
end
