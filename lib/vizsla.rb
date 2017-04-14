require 'vizsla/version'
require 'vizsla/middleware'
require 'vizsla/subscribers'
require 'vizsla/health_monitor'
require 'vizsla/worker_process_monitor'

module Vizsla
  class Agent
    @subscribers = Subscribers.new
    @health_monitor = HealthMonitor.start
    @worker_process_monitor = WorkerProcessMonitor.start
  end
end
