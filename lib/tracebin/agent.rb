require 'logger'

require 'tracebin/subscribers'
require 'tracebin/health_monitor'
require 'tracebin/worker_process_monitor'
require 'tracebin/storage'
require 'tracebin/reporter'

module Tracebin
  module Agent
    class << self
      attr_accessor :config, :storage, :logger

      def start!
        logger.info "TRACEBIN: Starting Tracebin agent..."

        @subscribers = Subscribers.new
        @health_monitor = HealthMonitor.start
        @worker_process_monitor = WorkerProcessMonitor.start

        @reporter = Reporter.new(storage, config, logger)

        @reporter.start!

        logger.info "TRACEBIN: Tracebin agent started!"
      end

      def stop!
        logger.info "TRACEBIN: Shutting down Tracebin agent..."

        @health_monitor.stop!
        @worker_process_monitor.stop!
        @reporter.stop!

        @started = false

        logger.info "TRACEBIN: Tracebin agent stopped!"
      end

      def started?
        @started
      end

      def init_logger
        if defined? ::Rails
          @logger = ::Rails.logger
        else
          @logger ||= Logger.new(STDOUT)
          @logger.level = log_level
        end

        @logger
      end

      def log_level
        case config.log_level.downcase
        when 'debug' then Logger::DEBUG
        when 'info' then Logger::INFO
        when 'warn' then Logger::WARN
        when 'error' then Logger::ERROR
        when 'fatal' then Logger::FATAL
        else Logger::INFO
        end
      end
    end

    def self.logger
      @logger || init_logger
    end

    def self.storage
      @storage ||= ::Tracebin::Storage.new
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
