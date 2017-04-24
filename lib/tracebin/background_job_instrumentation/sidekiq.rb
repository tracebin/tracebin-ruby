require 'tracebin/background_timer'
require 'tracebin/puppet_master'

module Tracebin
  module BackgroundJobInstrumentation
    class Sidekiq
      def call(worker, msg, queue, *args)
        timer = BackgroundTimer.new worker.class.name.split('::').last
        timer.start!

        yield

        timer.stop!

        PuppetMaster.new(timer, logger: worker.logger).process
      end
    end
  end
end
