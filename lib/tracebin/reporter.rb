require 'json'
require 'concurrent'

module Tracebin
  class Reporter
    attr_reader :logger, :config, :storage

    def initialize(storage = Tracebin::Agent.storage, config = Tracebin::Agent.config, logger = Tracebin::Agent.logger)
      @logger = logger
      @config = config
      @storage = storage
      @retry_limit = config.report_retry_limit

      if config.enable_ssl
        require 'net/https'
      else
        require 'net/http'
      end

      host = Tracebin::Agent.config.host
      path = Tracebin::Agent.config.report_path
      @uri = URI("#{host}/#{path}")

      @bin_id = Tracebin::Agent.config.bin_id
    end

    def start!
      freq = config.report_frequency >= 5 ? config.report_frequency : 5
      @retries = 0

      @task = Concurrent::TimerTask.new execution_interval: freq do
        unless storage.unloaded?
          payload = storage.unload
          res = send_data payload

          handle_response res, payload
        end
      end

      logger.info 'TRACEBIN: Reporter starting.'
      @task.execute
    end

    def stop!
      logger.info 'TRACEBIN: Reporter stopping. The agent will no longer report metrics to the server.'
      @task.shutdown if @task && @task.running?
    end

    private

    def send_data(payload)
      logger.info 'TRACEBIN: Sending analytics data to the server.'
      logger.info "TRACEBIN: Sending #{payload.length} samples to: #{@uri}"

      http = Net::HTTP.new @uri.host, @uri.port

      if config.enable_ssl
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      body = {
        bin_id: @bin_id,
        report: payload
      }.to_json

      req = Net::HTTP::Post.new @uri
      req.content_type = 'application/json'
      req.body = body

      res = http.request req
      logger.debug "TRACEBIN: Server responded with a status code of #{res.code}."

      res
    rescue Exception => e
      logger.warn "TRACEBIN: Exception occurred sending data to the server: #{e.message}"
      logger.debug "TRACEBIN: #{e.backtrace.join("\n\t")}"
      stop_all_agent_processes
    end

    def handle_response(res, payload)
      case res
      when Net::HTTPSuccess
        @retries = 0
        logger.info 'TRACEBIN: Successfully sent payload to the server.'
      when Net::HTTPNotFound
        logger.warn 'TRACEBIN: App bin ID not found. Please create a new app bin and add it to the config.'
        stop_all_agent_processes
      when Net::HTTPBadRequest
        logger.warn 'TRACEBIN: Something went wrong with the server. Please contact us!'
        stop_all_agent_processes
      when Net::HTTPRequestTimeout
        handle_timeout
      else
        logger.warn 'TRACEBIN: Failed to send data to the server.'
        stop_all_agent_processes
      end
    end

    def stop_all_agent_processes
      ::Tracebin::Agent.stop_parent_process
      ::Tracebin::Agent.stop_child_process
    end

    def handle_timeout
      if @retries < @retry_limit
        logger.info "TRACEBIN: Couldn't contact the server. Will try again in #{config.report_frequency} seconds."
        @storage.add_payload payload
        @retries += 1
      else
        logger.warn "TRACEBIN: Couldn't contact the server. Retry limit reached."
        stop_all_agent_processes
      end
    end
  end
end
