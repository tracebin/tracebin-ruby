require 'vizsla/system_health_sample'
require 'vizsla/puppet_master'
require 'concurrent'

module Vizsla
  class HealthMonitor
    class << self
      def start
        @task = Concurrent::TimerTask.new(execution_interval: 10) do
          health = SystemHealthSample.new
          PuppetMaster.new(health).process
        end

        @task.execute

        self
      end

      def stop!
        @task.shutdown
      end
    end
  end
end
