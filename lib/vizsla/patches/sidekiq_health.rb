require 'vizsla/patches' unless defined?(::Vizsla::Patches)
require 'vizsla/system_info'
require 'concurrent'

require 'sidekiq/processor'

::Sidekiq::Processor.class_eval do
  alias_method :initialize_without_vizsla, :initialize

  def initialize(boss)
    @vizsla_task = Concurrent::TimerTask.new(execution_interval: 10) do
      health = Vizsla::SystemInfo.new
      ::Vizsla::Patches.handle_event :sidekiq_health, health
    end

    @vizsla_task.execute

    initialize_without_vizsla(boss)
  end
end
