::Mysql2::Client.class_eval do
  alias_method :query_without_vizsla, :query

  def query(*args, &block)
    start_time   = Time.now
    result       = query_without_vizsla(*args, &block)
    end_time     = Time.now

    event_data = [
      'sql.mysql2_query',
      start_time,
      end_time,
      {
        sql: args[0]
      }
    ]

    ::Vizsla::Patches.handle_event :mysql2, event_data

    result
  end
end
