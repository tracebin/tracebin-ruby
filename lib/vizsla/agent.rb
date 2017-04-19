require 'vizsla/subscribers'
require 'vizsla/health_monitor'
require 'vizsla/worker_process_monitor'
require 'vizsla/storage'
require 'vizsla/reporter'

module Vizsla
  module Agent
    class << self
      attr_accessor :config, :storage

      @subscribers = Subscribers.new
      @health_monitor = HealthMonitor.start
      @worker_process_monitor = WorkerProcessMonitor.start
      @reporter = Reporter.new(storage)
      @reporter.start!
    end

    def self.storage
      @storage ||= ::Vizsla::Storage.new
    end

    def self.config
      @config ||= Config.new
    end

    def self.reset
      @config = Config.new
    end

    def self.configure
      yield config
    end
  end
end
