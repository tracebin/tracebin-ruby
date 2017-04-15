module Vizsla
  class SystemHealthSample
    DATA_TYPE = 'system_health_sample'.freeze

    def initialize(options = {})
      @process = options[:process] || :web
      @sampled_at = Time.new
      @metrics = sample_metrics
    end

    def payload
      {
        type: DATA_TYPE,

        data: {
          sampled_at: @sampled_at,

          metrics: @metrics
        }
      }
    end

    private

    def sample_metrics
      {
        process: @process.to_s,
        cpu: processor_info,
        memory: mem_info,
        disks: disk_info,
        machine_id: machine_info
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

      kernel = nil

      if darwin?
        kernel = 'darwin'
      elsif linux?
        kernel = 'linux'
      end

      {
        hostname: hostname,
        ip: ip_string,
        kernel: kernel
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
          total_memory: total,
          wired_memory: wired,
          free_memory: free,
          used_memory: used
        }
      elsif linux?
        total, cache, free, used, available = get_linux_memory_stats
        return {
          total_memory: total,
          wired_memory: cache,
          free_memory: free,
          used_memory: used,
          available_memory: available
        }
      end
    end

    def get_mach_memory_stats
      used, wired, free = `top -l 1 -s 0 | grep PhysMem`.scan(/\d+/)
      total = `sysctl -n hw.memsize`.to_i / 1024 / 1024
      [total.to_i, wired.to_i, free.to_i, used.to_i]
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
