require 'net/http'
require 'json'
require 'concurrent'

module Vizsla
  class Reporter
    def initialize
      @uri = URI('http://localhost:3000/cycle_transactions')
    end

    def send_data(payload)
      Concurrent::Future.execute { send_http payload }
    end

    def send_http(payload)
      Net::HTTP.start(@uri.host, @uri.port) do |http|
        body = { cycle_transaction: payload }.to_json

        req = Net::HTTP::Post.new @uri
        req.content_type = 'application/json'
        req.body = body

        res = http.request req
      end
    end
  end
end
