require 'vizsla/helpers'

module Vizsla
  class Patches
    include ::Vizsla::Helpers

    PATCH_METHOD_REGEX = /^patch_(.*)$/

    class << self
      def handle_event(handler_name, event_data)
        handler = self.instance_variable_get "@#{handler_name}_event_handler"
        handler.call event_data unless handler.nil?
      end

      def method_missing(method_sym, *args, &block)
        if method_sym.to_s =~ PATCH_METHOD_REGEX
          patch_name = $1
          require "vizsla/patches/#{patch_name}"
          self.instance_variable_set "@#{patch_name}_event_handler", block
        else
          super
        end
      end

      def respond_to?(method_sym, include_private = false)
        if method_sym.to_s =~ PATCH_METHOD_REGEX
          true
        else
          super
        end
      end
    end
  end
end
