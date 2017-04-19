require 'net/http'
require 'json'
require 'concurrent'

module Vizsla
  class Reporter
    def initialize(storage)
      @storage = storage

      host = Vizsla::Agent.config.host
      path = Vizsla::Agent.config.report_path
      @uri = URI("#{host}/#{path}")

      @bin_id = Vizsla::Agent.config.bin_id
    end

    def start!
      @task = Concurrent::TimerTask.new do
        unless @storage.unloaded?
          payload = @storage.unload
          send_http payload
        end
      end
    end

    private

    def send_http(payload)
      Net::HTTP.start(@uri.host, @uri.port) do |http|
        body = {
          bin_id: @bin_id,
          report: payload
        }.to_json

        req = Net::HTTP::Post.new @uri
        req.content_type = 'application/json'
        req.body = body

        res = http.request req
      end
    end
  end
end
