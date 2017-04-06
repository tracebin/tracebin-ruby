module Vizsla
  module SystemInfo
    def self.ruby_os_identifier
      RbConfig::CONFIG['target_os']
    end

    def self.darwin?
      !!(ruby_os_identifier =~ /darwin/i)
    end

    def self.linux?
      !!(ruby_os_identifier =~ /linux/i)
    end

    def self.processor_info
      info = {}

      if darwin?
        info[:model_name] = get_sysctl_value('machdep.cpu.brand_string')
        info[:processor_count] = get_sysctl_value('hw.packages').to_i
        info[:core_count] = get_sysctl_value('hw.physicalcpu_max').to_i,
        info[:logical_cpu_count] = get_sysctl_value('hw.logicalcpu_max').to_i
      elsif linux?
        proc_string = read_proc('/proc/cpuinfo')
        info = parse_proc_cpuinfo_string(proc_string)
      end
    end

    def self.get_sysctl_value(key)
      `sysctl -n #{key} 2>/dev/null`
    end

    def self.read_proc(path)
      return nil unless File.exist? path
      `cat #{path} 2>/dev/null`
    end

    def self.parse_proc_cpuinfo_string(proc_string)
      threads = proc_string.split(/\n\n/).map { |core| core.split(/\n/) }

      units = {}
      cores = {}
      model_name = nil

      threads.each do |thread|
        thread.each do |line|
          if matched_line = line.match(/physical\ id\s*\:\s*(\d)/i)
            id = matched_line[1]
            units[id] = true
          elsif matched_line = line.match(/core \id\s*\:\s*(\d)/i)
            id = matched_line[1]
            cores[id] = true
          elsif matched_line = line.match(/model\ name\s*\:\s*(.*)/i)
            model_name = matched_line[1] unless model_name
          end
        end
      end

      {
        model_name: model_name
        processor_count: units.count,
        core_count: cores.count,
        logical_cpu_count: threads.count
      }
    end
  end
end
