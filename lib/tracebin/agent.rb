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

      def start_parent_process
        return if parent_process_started? || !config.enabled

        logger.info "TRACEBIN: Starting Tracebin parent process..."
        init_storage

        @subscribers = Subscribers.new
        @health_monitor = HealthMonitor.start
        @worker_process_monitor = WorkerProcessMonitor.start

        @parent_process_reporter = Reporter.new
        @parent_process_reporter.start!

        @parent_process_started = true
        logger.info "TRACEBIN: Tracebin parent process started!"
      rescue => e
        logger.info "TRACEBIN: Error occurred while trying to start parent process: #{e.message}"
      end

      def start_child_process
        return if child_process_started? || !config.enabled

        logger.info "TRACEBIN: Starting Tracebin child process..."
        init_storage

        @child_process_reporter = Reporter.new
        @child_process_reporter.start!

        @child_process_started = true
        logger.info "TRACEBIN: Tracebin child process started!"
      rescue => e
        logger.info "TRACEBIN: Error occurred while trying to start child process: #{e.message}"
      end

      def stop_parent_process
        return unless parent_process_started?

        logger.info "TRACEBIN: Shutting down parent process..."

        @health_monitor.stop!
        @worker_process_monitor.stop!
        @parent_process_reporter.stop!

        storage.unload

        @parent_process_started = false

        logger.info "TRACEBIN: Parent process stopped!"
      end

      def stop_child_processes
        return unless child_process_started?

        logger.info "TRACEBIN: Shutting down child process..."

        @child_process_reporter.stop!

        storage.unload

        @child_process_started = false

        logger.info "TRACEBIN: Child process stopped!"
      end

      def parent_process_started?
        @parent_process_started
      end

      def child_process_started?
        @child_process_started
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

      def init_storage
        @storage = ::Tracebin::Storage.new
      end
    end

    def self.logger
      @logger || init_logger
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
