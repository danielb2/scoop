module Scoop
  class Builder
    attr_accessor :output, :config
    def initialize
      @output = StringIO.new
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
        run_build_tasks
        run_deploy_tasks
        sleep 1 # we don't want to eat cpu incase the update is wonky
      end
    end

    def update?
      result = exec(version_control.update_cmd)
      return false if result =~ /up-to-date./
      return true
    end

    # also store result later for output to email
    def exec(cmd)
      debug cmd
      result = nil
      Bundler.with_clean_env do
        Dir.chdir config[:build_dir] do
          result = `#{cmd} 2>&1`
        end
      end
      debug result.chomp
      return result
    end

    def debug(str)
      logger.debug str if Scoop[:debug]
    end

    # has there been an update in the repo we need to build for?
    def email_results
    end

    def run_build_tasks
      exec config[:build_tasks]
    end
    def run_deploy_tasks
      exec config[:deploy_tasks]
    end
  end
end
