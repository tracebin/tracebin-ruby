require 'net/https'
require 'json'
require 'concurrent'

module Tracebin
  class Reporter
    attr_reader :logger, :config, :storage

    def initialize(storage = Tracebin::Agent.storage, config = Tracebin::Agent.config, logger = Tracebin::Agent.logger)
      @logger = logger
      @config = config
      @storage = storage

      host = Tracebin::Agent.config.host
      path = Tracebin::Agent.config.report_path
      @uri = URI("#{host}/#{path}")

      @bin_id = Tracebin::Agent.config.bin_id
    end

    def start!
      @task = Concurrent::TimerTask.new do
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
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

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
      Tracebin::Agent.stop!
    end

    def handle_response(res, payload)
      case res
      when Net::HTTPSuccess
        logger.info 'TRACEBIN: Successfully sent payload to the server.'
      when Net::HTTPBadRequest
        logger.warn 'TRACEBIN: App bin ID not found. Please create a new app bin and add it to the config.'
        Tracebin::Agent.stop!
      else
        logger.warn 'TRACEBIN: Failed to send data to the server. Will try again in 1 minute.'
        @storage.add_payload payload
      end
    end
  end
end
