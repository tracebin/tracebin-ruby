require 'vizsla/background_timer'
require 'vizsla/puppet_master'

if defined? ::ActiveJob::Base
  ::ActiveJob::Base.around_perform do |job, block|
    @vizsla_timer = ::Vizsla::BackgroundTimer.new job.class.name.split('::').last
    @vizsla_timer.start!

    block.call

    @vizsla_timer.stop!
    ::Vizsla::PuppetMaster.new(@vizsla_timer).process
  end
end
