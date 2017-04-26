require 'tracebin/timer'
require 'tracebin/puppet_master'

module Tracebin
  class Middleware
    attr_reader :config, :logger

    def initialize(app)
      @app = app
      @config = Tracebin::Agent.config
      @logger = Tracebin::Agent.logger

      start_agent
    end

    def call(env)
      dup.__call(env)
    end

    def __call(env)
      if agent_disabled?(env)
        return @app.call env
      else
        @tracebin_timer = Timer.new
        @tracebin_timer.start!

        status, headers, response = @app.call(env)

        @tracebin_timer.transaction_name = fetch_endpoint_name(env)

        @tracebin_timer.stop!

        PuppetMaster.new(@tracebin_timer).process

        return [status, headers, response]
      end
    end

    private

    def fetch_endpoint_name(env)
      if controller = env['action_controller.instance']
        "#{controller.class}##{controller.params['action']}"
      elsif route = env['sinatra.route']
        route
      else
        'RackTransaction'
      end
    end

    def start_agent
      Tracebin::Agent.start!
    rescue => e
      @logger.warn "TRACEBIN: Failed to start agent: #{e.message}"
    end

    def agent_disabled?(env)
      path = env['REQUEST_PATH']
      ignored_paths = config.ignored_paths.map { |root| %r{^#{root}} }

      !Tracebin::Agent.started? ||
        ignored_paths.any? { |root| !!root.match(path) }
    end
  end
end
