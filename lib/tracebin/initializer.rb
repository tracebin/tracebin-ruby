module Tracebin
  module Initializer
    class << self
      def start!
        if forking_server?
          # This will not work yet.
          Tracebin::Agent.start!
        else
          Tracebin::Agent.start!
        end
      end

      private

      def forking_server?
        defined? ::Puma
      end
    end
  end
end
