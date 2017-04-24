require 'tracebin/patches'
require 'tracebin/puppet_master'

module Tracebin
  class WorkerProcessMonitor
    class << self
      def start
        sidekiq_health_patch

        self
      end

      def stop!
      end

      def sidekiq_health_patch
        return unless defined? ::Sidekiq

        ::Tracebin::Patches.patch_sidekiq_health do |health_data|
          ::Tracebin::PuppetMaster.new(health_data, logger: ::Sidekiq::Logging.logger).process
        end
      end
    end
  end
end
