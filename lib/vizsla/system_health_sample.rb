module Vizsla
  class SystemHealthSample
    def initialize(options = {})
      @process = options[:process] || :web
      @metrics = sample_metrics
    end

    def payload
      {
        type: 'system_health_sample',

        data: {
          sampled_at: Time.now,

          metrics: @metrics
        }
      }
    end

    private

    def sample_metrics
      {
        process: @process.to_s,
        CPU: processor_info,
        Memory: mem_info,
        Disks: disk_info,
        Machine_id: machine_info
      }
    end

    def ruby_os_identifier
      RbConfig::CONFIG['target_os']
    end

    def darwin?
      !!(ruby_os_identifier =~ /darwin/i)
    end

    def linux?
      !!(ruby_os_identifier =~ /linux/i)
    end

    def machine_info
      ip_string = `dig +short myip.opendns.com @resolver1.opendns.com`.strip
      hostname = `hostname`.strip
      {
        hostname: hostname,
        ip: ip_string
      }
    end

    def disk_info(disks = ["disk0"])
      if darwin?
        read_iostat(disks)
      elsif linux?
        parse_proc
      end
    end

    def parse_proc
      {
        load_average: `cat /proc/loadavg | awk '{print $1,$2,$3}'`.strip
      }
    end

    def read_iostat(disks)
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
        disks_info[disk_name] = {
          kb_per_trans: disk_stats[0].to_f,
          trans_num: disk_stats[1].to_f,
          mb_per_sec: disk_stats[2].to_f
        }
      end
      disks_info
    end

    def mem_info
      if darwin?
        total, wired, free, used = get_mach_memory_stats
        return {
          total_memory: total + " MB",
          wired_memory: wired + " MB",
          free_memory: free + " MB",
          used_memory: used + " MB"
        }
      elsif linux?
        total, cache, free, used, available = get_linux_memory_stats
        return {
          total_memory: total + " MB",
          wired_memory: cache + " MB",
          free_memory: free + " MB",
          used_memory: used + " MB",
          available_memory: available + " MB"
        }
      end
    end

    def get_mach_memory_stats
      used, wired, free = `top -l 1 -s 0 | grep PhysMem`.scan(/\d+/)
      total = `sysctl -n hw.memsize`.to_i / 1024 / 1024
      [total.to_s, wired, free, used]
    end

    def get_linux_memory_stats
      total, used, free, _, cache, available = `free | grep Mem`.scan(/\d+/).map { |mem_stat| mem_stat.to_i / 1024 }
      [total.to_s, cache.to_s, free.to_s, used.to_s, available.to_s]
    end

    def processor_info
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

    def get_sysctl_value(key)
      `sysctl -n #{key} 2>/dev/null`
    end

    def read_proc(path)
      return nil unless File.exist? path
      `cat #{path} 2>/dev/null`
    end

    def parse_proc_cpuinfo_string(proc_string)
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
  end
end
