require 'vizsla/timer'
require 'vizsla/puppet_master'

module Vizsla
  class Middleware
    def initialize(app)
      @app = app

      Vizsla::Agent.start! unless Vizsla::Agent.started?
    end

    def call(env)
      dup.__call(env)
    end

    def __call(env)
      timer = Timer.new
      timer.start!

      status, headers, response = @app.call(env)

      timer.transaction_name = fetch_endpoint_name env

      timer.stop!

      PuppetMaster.new(timer).process

      [status, headers, response]
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
