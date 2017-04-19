require 'vizsla/patches'
require 'vizsla/system_health_sample'
require 'concurrent'

require 'sidekiq/launcher'

::Sidekiq::Launcher.class_eval do
  alias_method :run_without_vizsla, :run
  alias_method :stop_without_vizsla, :stop

  def run
    @vizsla_task = Concurrent::TimerTask.new(execution_interval: 10) do
      health = Vizsla::SystemHealthSample.new process: :worker
      ::Vizsla::Patches.handle_event :sidekiq_health, health
    end

    @vizsla_task.execute

    run_without_vizsla
  end

  def stop
    @vizsla_task.shutdown

    stop_without_vizsla
  end
end
