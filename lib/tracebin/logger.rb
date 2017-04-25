module Tracebin
  class RequestLogger
    def initialize(logger_override = nil)
      @logger_override = logger_override
    end

    def display_payload(payload)
      output = '=' * 50 + "\n"

      str_append_hash output, payload

      output += '=' * 50

      log output
    end

    def str_append_hash(str, hsh, bumper = '')
      hsh.keys.each do |key|
        if hsh[key].is_a? Hash
          str << "#{bumper}#{key}:\n"
          str_append_hash str, hsh[key], bumper + '  '
        elsif hsh[key].is_a? Array
          str << "#{bumper}#{key}:\n"
          hsh[key].each do |ele|
            if ele.is_a? Hash
              str_append_hash str, ele, bumper + '  '
            else
              str << "#{bumper}#{ele}\n"
            end
          end
        else
          str << "#{bumper}#{key}: #{hsh[key]}\n"
        end
      end

      str
    end

    private

    def rails_app?
      defined? ::Rails
    end

    def log(text)
      if !@logger_override.nil?
        @logger_override.info text
      elsif rails_app?
        Rails.logger.debug text
      else
        puts text
      end
    end
  end
end
