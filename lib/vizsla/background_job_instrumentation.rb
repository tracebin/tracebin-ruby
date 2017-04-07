module Vizsla
  module BackgroundJobInstrumentation
    def self.install(inst_name)
      self.send inst_name
    end

    def self.sidekiq
      require 'vizsla/background_job_instrumentation/sidekiq'

      ::Sidekiq.configure_server do |config|
        config.server_middleware do |chain|
          chain.add ::Vizsla::BackgroundJobInstrumentation::Sidekiq
        end
      end
    end
  end
end
