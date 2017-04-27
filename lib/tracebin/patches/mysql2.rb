::Mysql2::Client.class_eval do
  alias_method :query_without_tracebin, :query

  def query(*args, &block)
    start_time   = ::Tracebin::PatchHelper.timestamp_string
    result       = query_without_tracebin(*args, &block)
    end_time     = ::Tracebin::PatchHelper.timestamp_string

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
