require 'vizsla/version'
require 'vizsla/middleware'
require 'vizsla/subscribers'
require 'vizsla/health_monitor'

module Vizsla
  class Agent
    @subscribers = Subscribers.new
    @health_monitor = HealthMonitor.start
  end
end
