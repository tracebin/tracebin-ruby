require 'vizsla/patches'
require 'vizsla/puppet_master'

module Vizsla
  class WorkerProcessMonitor
    class << self
      def start
        sidekiq_health_patch

        self
      end

      def sidekiq_health_patch
        return unless defined? ::Sidekiq
        ::Vizsla::Patches.patch_sidekiq_health do |health_data|
          ::Vizsla::PuppetMaster.new(health_data).process
        end
      end
    end
  end
end
