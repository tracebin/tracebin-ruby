require 'tracebin/version'
require 'tracebin/config'
require 'tracebin/subscribers'
require 'tracebin/health_monitor'
require 'tracebin/worker_process_monitor'
require 'tracebin/agent'
require 'tracebin/middleware'

if defined?(::Rails) && defined?(::Rails::Railtie)
  module Tracebin
    class Railtie < Rails::Railtie
      initializer 'tracebin.start' do |app|
        app.middleware.use Tracebin::Middleware
      end
    end
  end
end
