require 'vizsla/background_timer'
require 'vizsla/puppet_master'

module Resque
  module Plugins
    module VizslaInstrumentation
      module Job
        def before_perform_with_vizsla(*args)
          @vizsla_timer = ::Vizsla::BackgroundTimer.new
          @vizsla_timer.start!

          yield *args if block_given?
        end

        def after_perform_with_vizsla(*args)
          @vizsla_timer.stop!
          ::Vizsla::PuppetMaster.new(@vizsla_timer, logger: Resque.logger).process

          yield *args if block_given?
        end
      end
    end
  end
end

module Vizsla
  module BackgroundJobInstrumentation
    module ResqueInstrumentationInstaller
      def payload_class
        klass = super
        klass.instance_eval do
          extend ::Resque::Plugins::VizslaInstrumentation::Job
        end
      end
    end
  end
end
