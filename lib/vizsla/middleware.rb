require 'vizsla/timer'
require 'vizsla/puppet_master'

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

      PuppetMaster.new(timer).process

      [status, headers, response]
    end
  end
end
