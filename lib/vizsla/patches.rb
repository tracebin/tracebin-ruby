require 'vizsla/helpers'

module Vizsla
  class Patches
    include ::Vizsla::Helpers

    class << self
      def patch_mysql2(&block)
        @mysql2_event_handler = block

        ::Mysql2::Client.class_eval do
          alias_method :query_without_profiling, :query

          def query(*args, &block)
            start_time   = Time.now
            result       = query_without_profiling(*args, &block)
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
      end

      def patch_postgres(&block)
        @postgres_event_handler = block

        ::PG::Connection.class_eval do
          alias_method :exec_without_profiling, :exec
          alias_method :exec_params_without_profiling, :exec_params

          def exec_params(*args, &block)
            start_time   = Time.now
            result       = exec_params_without_profiling(*args, &block)
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

          def exec(*args, &block)
            start_time   = Time.now
            result       = exec_without_profiling(*args, &block)
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

      def patch_sinatra(&block)
        @sinatra_event_handler = block
        ::Sinatra::Base.class_eval do
          alias_method :dispatch_without_profiling!, :dispatch!

          def dispatch!(*args, &block)
            start_time = Time.now
            result = dispatch_without_profiling!(*args, *block)
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
      end

      def handle_event(handler_name, event_data)
        handler = self.instance_variable_get "@#{handler_name}_event_handler"
        handler.call event_data unless handler.nil?
      end
    end
  end
end
