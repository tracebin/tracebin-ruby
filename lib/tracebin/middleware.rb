require 'tracebin/timer'
require 'tracebin/puppet_master'

module Tracebin
  class Middleware
    attr_reader :config

    def initialize(app)
      @app = app
      @config = Tracebin::Agent.config

      Tracebin::Agent.start! unless Tracebin::Agent.started?
    end

    def call(env)
      dup.__call(env)
    end

    def __call(env)
      path = env['REQUEST_PATH']
      ignored_paths = config.ignored_paths.map { |root| %r{^#{root}} }

      if ignored_paths.any? { |root| !!root.match(path) }
        @app.call env
      else
        timer = Timer.new
        timer.start!

        status, headers, response = @app.call(env)

        timer.transaction_name = fetch_endpoint_name env

        timer.stop!

        PuppetMaster.new(timer).process

        [status, headers, response]
      end
    end

    private

    def fetch_endpoint_name(env)
      if controller = env['action_controller.instance']
        "#{controller.class}##{controller.params['action']}"
      else
        'RackTransaction'
      end
    end
  end
end
