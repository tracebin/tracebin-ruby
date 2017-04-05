require 'vizsla/helpers'

module Vizsla
  class Patches
    include ::Vizsla::Helpers

    class << self
      def patch_postgres
        if block_given?
          @postgres_event_hanlder = Proc.new(&block)
        end

        ::PG::Connection.class_eval do
          alias_method :exec_without_profiling, :exec

          def exec(*args, &blk)
            return exec_without_profiling(*args, &blk)

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
        handler = self.get_instance_variable "@#{handler_name}_event_handler"
        hanlder.call event_data unless hanlder.nil?
      end
    end
  end
end
