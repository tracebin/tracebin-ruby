require 'vizsla/version'
require 'vizsla/config'
require 'vizsla/subscribers'
require 'vizsla/health_monitor'
require 'vizsla/worker_process_monitor'
require 'vizsla/agent'
require 'vizsla/middleware'

if defined?(::Rails) && defined?(::Rails::Railtie)
  module Vizsla
    class Railtie < Rails::Railtie
      initializer 'vizsla.start' do |app|
        app.middleware.use Vizsla::Middleware
      end
    end
  end
end
