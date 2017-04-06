module Vizsla
  class SystemInfo
    def self.ruby_os_identifier
      RbConfig::CONFIG['target_os']
    end

    def self.darwin?
      !!(ruby_os_identifier =~ /darwin/i)
    end

    def self.linux?
      !!(ruby_os_identifier =~ /linux/i)
    end

    # expects an array of disks to monitor
    def self.disk_info(disks = ["disk0"])
      if darwin?
        read_iostat(disks)
      elsif linux?
        # output is very different. Will need a new parser method
        raise NotImplementedError
      end
    end

    def self.read_iostat(disks)
      disks_info = {}
      captured_data = []

      disks.each do |disk|
        disk_data = `iostat -Ud #{disk}`.strip.split(/\n/)
        captured_data << disk_data
        disks_info["load_average"] = disk_data.last.strip.split(/\s+/)[3..-1].map(&:to_f) unless disks_info["load_average"]
      end

      captured_data.each_with_index do |disk, index|
        disk_name = disks[index]
        disk_stats = disk.last.strip.split(/\s+/)[0, 3]
        disks_info[disk_name] = disk_stats
      end
      disks_info
    end

    def self.mem_info
      {}
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
      info
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
          elsif matched_line = line.match(/core\ id\s*\:\s*(\d)/i)
            id = matched_line[1]
            cores[id] = true
          elsif matched_line = line.match(/model\ name\s*\:\s*(.*)/i)
            model_name = matched_line[1] unless model_name
          end
        end
      end

      {
        model_name: model_name,
        processor_count: units.count,
        core_count: cores.count,
        logical_cpu_count: threads.count
      }
    end

    def all_data
      cpu_data = self.class.processor_info
      mem_data = self.class.mem_info
      disk_data = self.class.disk_info
      {
        CPU: cpu_data,
        Memory: mem_data,
        Disks: disk_data
      }
    end
  end
end
