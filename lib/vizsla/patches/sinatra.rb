::Sinatra::Base.class_eval do
  alias_method :dispatch_without_vizsla!, :dispatch!

  def dispatch!(*args, &block)
    start_time = Time.now
    result = dispatch_without_vizsla!(*args, *block)
    end_time = Time.now
    route = env['sinatra.route']

    event_data = [
      'sinatra.route_exec',
      start_time,
      end_time,
      route
    ]

    ::Vizsla::Patches.handle_event :sinatra, event_data

    result
  end
end
