module Vizsla
  class Config
    DEFAULTS = {
      host: 'http://localhost:3000',
      report_path: 'reports'
    }.freeze

    attr_accessor *(DEFAULTS.keys + [:bin_id])

    def initialize(config = {})
      opts = DEFAULTS.merge config
      opts.keys.each do |key|
        if self.respond_to? key
          self.instance_variable_set "@#{key}", opts[key]
        end
      end
    end
  end
end
