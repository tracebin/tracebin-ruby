require 'vizsla/background_timer'
require 'vizsla/puppet_master'

module Vizsla
  module BackgroundJobInstrumentation
    class Sidekiq
      def call(worker, msg, queue, *args)
        timer = BackgroundTimer.new
        timer.start!

        yield

        timer.stop!

        PuppetMaster.new(timer, logger: worker.logger).process
      end
    end
  end
end
