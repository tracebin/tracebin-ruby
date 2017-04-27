::Sinatra::Base.class_eval do
  alias_method :dispatch_without_tracebin!, :dispatch!

  def dispatch!(*args, &block)
    start_time = ::Tracebin::PatchHelper.timestamp_string
    result = dispatch_without_tracebin!(*args, *block)
    end_time = ::Tracebin::PatchHelper.timestamp_string
    route = env['sinatra.route']

    event_data = [
      'sinatra.route',
      start_time,
      end_time,
      {
        endpoint: route
      }
    ]

    ::Tracebin::Patches.handle_event :sinatra, event_data

    result
  end
end
