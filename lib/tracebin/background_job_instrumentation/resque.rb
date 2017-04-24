require 'tracebin/background_timer'
require 'tracebin/puppet_master'

module Resque
  module Plugins
    module TracebinInstrumentation
      module Job
        def before_perform_with_tracebin(*args)
          @tracebin_timer = ::Tracebin::BackgroundTimer.new
          @tracebin_timer.start!

          yield *args if block_given?
        end

        def after_perform_with_tracebin(*args)
          @tracebin_timer.stop!
          ::Tracebin::PuppetMaster.new(@tracebin_timer, logger: Resque.logger).process

          yield *args if block_given?
        end
      end
    end
  end
end

module Tracebin
  module BackgroundJobInstrumentation
    module ResqueInstrumentationInstaller
      def payload_class
        klass = super
        klass.instance_eval do
          extend ::Resque::Plugins::TracebinInstrumentation::Job
        end
      end
    end
  end
end
