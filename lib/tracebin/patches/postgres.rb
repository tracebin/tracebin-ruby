::PG::Connection.class_eval do
  alias_method :exec_without_tracebin, :exec
  alias_method :exec_params_without_tracebin, :exec_params

  def exec_params(*args, &block)
    start_time   = ::Tracebin::PatchHelper.timestamp_string
    result       = exec_params_without_tracebin(*args, &block)
    end_time     = ::Tracebin::PatchHelper.timestamp_string

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
    start_time   = ::Tracebin::PatchHelper.timestamp_string
    result       = exec_without_tracebin(*args, &block)
    end_time     = ::Tracebin::PatchHelper.timestamp_string

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
