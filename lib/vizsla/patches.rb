require 'vizsla/helpers'

module Vizsla
  class Patches
    include ::Vizsla::Helpers

    class << self
      def patch_postgres(&blk)
        @postgres_event_handler = blk

        ::PG::Connection.class_eval do
          alias_method :exec_without_profiling, :exec
          alias_method :exec_params_without_profiling, :exec_params

          def exec_params(*args, &blk)
            start_time   = Time.now
            result       = exec_params_without_profiling(*args, &blk)
            end_time     = Time.now

            require 'pry'; binding.pry

            event_data = [
              'sql.postgres_exec',
              start_time,
              end_time,
              {
                sql: args[0]
              }
            ]

            ::Vizsla::Patches.handle_event :postgres, event_data

            result
          end

          def exec(*args, &blk)
            start_time   = Time.now
            result       = exec_without_profiling(*args, &blk)
            end_time     = Time.now

            event_data = [
              'sql.postgres_exec',
              start_time,
              end_time,
              {
                sql: args[0]
              }
            ]

            ::Vizsla::Patches.handle_event :postgres, event_data

            result
          end
        end
      end

      def handle_event(handler_name, event_data)
        handler = self.instance_variable_get "@#{handler_name}_event_handler"
        handler.call event_data unless handler.nil?
      end
    end
  end
end
