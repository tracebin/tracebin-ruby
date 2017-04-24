require 'tracebin/background_timer'
require 'tracebin/puppet_master'

if defined? ::ActiveJob::Base
  ::ActiveJob::Base.around_perform do |job, block|
    @tracebin_timer = ::Tracebin::BackgroundTimer.new job.class.name.split('::').last
    @tracebin_timer.start!

    block.call

    @tracebin_timer.stop!
    ::Tracebin::PuppetMaster.new(@tracebin_timer).process
  end
end
