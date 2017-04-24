::PG::Connection.class_eval do
  alias_method :exec_without_tracebin, :exec
  alias_method :exec_params_without_tracebin, :exec_params

  def exec_params(*args, &block)
    start_time   = Time.now
    result       = exec_params_without_tracebin(*args, &block)
    end_time     = Time.now

    event_data = [
      'sql.postgres_exec',
      start_time,
      end_time,
      {
        sql: args[0]
      }
    ]

    ::Tracebin::Patches.handle_event :postgres, event_data

    result
  end

  def exec(*args, &block)
    start_time   = Time.now
    result       = exec_without_tracebin(*args, &block)
    end_time     = Time.now

    event_data = [
      'sql.postgres_exec',
      start_time,
      end_time,
      {
        sql: args[0]
      }
    ]

    ::Tracebin::Patches.handle_event :postgres, event_data

    result
  end
end
