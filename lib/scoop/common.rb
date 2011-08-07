module Scoop
  module Common
    def config
      App.conf
    end
    def logger
      @logger ||= Scoop[:debug] ? Logger.new($stdout) : Logger.new(config[:logfile])
    end
    def debug(str)
      logger.debug str if Scoop[:debug]
    end

    class ExecError < Exception
      attr_reader :cmd, :status, :output

      def initialize(cmd, status, output)
        @cmd, @status, @output = cmd, status, output
        super("Error executing #{@cmd.inspect} (status #{@status.inspect}) -> #{@output.inspect}")
      end
    end

    def shell(cmd)
      result = ''
      process_status = nil
      puts cmd
      Open3.popen3("#{cmd} 2>&1") do |stdin, stdout, stderr, wait_thr|
        begin
          while line = stdout.sysread(15)
            result += line
            print line
          end
        rescue EOFError
        end
        process_status = wait_thr.value
      end
      status = process_status.exitstatus
      raise ExecError.new(cmd, status, result) unless status == 0
      return result
    end

    protected
    def config_file
      Scoop[:config_file] || YAML.load_file((Scoop.root + 'config/config.yml').to_s)
    end
  end
end
