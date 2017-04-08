module Vizsla
  module BackgroundJobInstrumentation
    def self.install(inst_name)
      self.send inst_name
    end

    private

    def self.sidekiq
      require 'vizsla/background_job_instrumentation/sidekiq'

      ::Sidekiq.configure_server do |config|
        config.server_middleware do |chain|
          chain.add ::Vizsla::BackgroundJobInstrumentation::Sidekiq
        end
      end
    end

    def self.resque
      require 'vizsla/background_job_instrumentation/resque'

      ::Resque::Job.class_eval do
        def self.new(*args)
          super(*args).extend ::Vizsla::BackgroundJobInstrumentation::
            ResqueInstrumentationInstaller
        end
      end
    end
  end
end
