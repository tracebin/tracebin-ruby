module Tracebin
  module BackgroundJobInstrumentation
    def self.install(inst_name)
      self.send inst_name
    end

    private

    def self.sidekiq
      require 'tracebin/background_job_instrumentation/sidekiq'

      ::Sidekiq.configure_server do |config|
        config.server_middleware do |chain|
          chain.add ::Tracebin::BackgroundJobInstrumentation::Sidekiq
        end
      end
    end

    def self.resque
      require 'tracebin/background_job_instrumentation/resque'

      ::Resque::Job.class_eval do
        def self.new(*args)
          super(*args).extend ::Tracebin::BackgroundJobInstrumentation::
            ResqueInstrumentationInstaller
        end
      end
    end

    def self.active_job
      require 'tracebin/background_job_instrumentation/active_job'
    end
  end
end
