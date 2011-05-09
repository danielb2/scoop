module Scoop
  class Builder
    attr_accessor :output, :config, :exec_status, :status
    SUCCESS       = 1
    FAILED_BUILD  = 2
    FAILED_DEPLOY = 3

    def initialize
      @output = StringIO.new
      @status = SUCCESS
      FileUtils.mkdir_p config[:build_dir]
    end

    #version 
    def version_control
      Scoop::Adapter.const_get(config[:adapter].downcase.capitalize).new(config,logger)
      rescue NameError
        nil
    end

    def config
      return @config if @config
      root = Scoop.root
      @config = YAML::load(ERB.new( IO.read( config_file ) ).result(binding) )
    end

    def config_file
      Scoop[:config_file] || YAML.load_file((Scoop.root + 'config/config.yml').to_s)
    end

    def logger
      @logger ||= Logger.new(config[:logfile])
    end


    def run
      loop do
        if !update?
          debug "no update found."
          sleep config[:poll_interval]
          next
        end
        debug "found update."
        if run_build_tasks
          if run_deploy_tasks
          end
        else
        end
        email_results
        sleep 1 # we don't want to eat cpu incase the update is wonky
      end
    end

    def update?
      exec("rsync -az --delete #{config[:source_dir]}/ #{config[:build_dir]}")
      result = exec(version_control.update_cmd)
      return false if result =~ /up-to-date./
      return true
    end

    # also store result later for output to email
    def exec(cmd)
      debug "Executing: #{cmd}"
      result = nil
      Bundler.with_clean_env do
        Dir.chdir config[:build_dir] do
          result = `#{cmd} 2>&1`
          @exec_status = $?.exitstatus
        end
      end
      debug result.chomp
      return result
    end

    def debug(str)
      logger.debug str if Scoop[:debug]
    end

    def email_results
      debug "emailing results"

      settings = config[:email]
      smtp     = settings[:smtp]

      args = [smtp[:host], smtp[:port], smtp[:account],
        smtp[:password], smtp[:authentication]]
      smtp_conn = Net::SMTP.new(smtp[:host], smtp[:port])
      smtp_conn.enable_starttls
      smtp_conn.start(smtp[:host], smtp[:account], smtp[:password], smtp[:authentication])
      Mail.defaults do
        delivery_method :smtp_connection, { :connection => smtp_conn }
      end
      mail = Mail.new do
        to settings[:to]
        from settings[:from]
        subject 'test'
        body 'testing sendmail'
      end
      mail.deliver!
      debug "email sent"
    end
    def email_subject
      subject = status == SUCCESS ? 'SUCCESS: ' : 'FAILED: '
      # note who made the latest build
      # trimmed last commit message in subject
    end

    def run_build_tasks
      output << exec(config[:build_tasks])
      if exec_status != 0
        logger.warning "build tasks failed"
        self.status = FAILED_BUILD
        return false
      end
      return true
    end

    def run_deploy_tasks
      result = exec(config[:deploy_tasks])
      if exec_status != 0
        logger.warning "deploy tasks failed"
        self.status = FAILED_DEPLOY
      end
    end
  end
end
