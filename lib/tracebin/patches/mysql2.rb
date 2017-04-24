::Mysql2::Client.class_eval do
  alias_method :query_without_tracebin, :query

  def query(*args, &block)
    start_time   = Time.now
    result       = query_without_tracebin(*args, &block)
    end_time     = Time.now

    event_data = [
      'sql.mysql2_query',
      start_time,
      end_time,
      {
        sql: args[0]
      }
    ]

    ::Tracebin::Patches.handle_event :mysql2, event_data

    result
  end
end
