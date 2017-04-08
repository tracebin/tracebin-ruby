require 'vizsla/system_info'
require 'concurrent'

module Vizsla
  class HealthMonitor
    class << self
      def start
        @task = Concurrent::TimerTask.new(execution_interval: 10) do
          health = SystemInfo.new
          PuppetMaster.new(health).process
        end

        @task.execute

        self
      end
    end
  end
end
