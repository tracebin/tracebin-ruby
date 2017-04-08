require 'vizsla/patches' unless defined?(::Vizsla::Patches)
require 'vizsla/system_info'
require 'concurrent'

require 'sidekiq/launcher'

::Sidekiq::Launcher.class_eval do
  alias_method :run_without_vizsla, :run

  def run
    @vizsla_task = Concurrent::TimerTask.new(execution_interval: 10) do
      health = Vizsla::SystemInfo.new process: :worker
      ::Vizsla::Patches.handle_event :sidekiq_health, health
    end

    @vizsla_task.execute

    run_without_vizsla
  end
end
