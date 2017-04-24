require 'tracebin/patches'
require 'tracebin/system_health_sample'
require 'concurrent'

require 'sidekiq/launcher'

::Sidekiq::Launcher.class_eval do
  alias_method :run_without_tracebin, :run
  alias_method :stop_without_tracebin, :stop

  def run
    @tracebin_task = Concurrent::TimerTask.new(execution_interval: 10) do
      health = Tracebin::SystemHealthSample.new process: :worker
      ::Tracebin::Patches.handle_event :sidekiq_health, health
    end

    @tracebin_task.execute

    run_without_tracebin
  end

  def stop
    @tracebin_task.shutdown

    stop_without_tracebin
  end
end
