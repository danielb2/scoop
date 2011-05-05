module Scoop
  class Builder
    attr_accessor :output, :config
    def initialize
      @output = StringIO.new
    end

    #version 
    def version_control
      Scoop::Adapter.const_get(config[:adapter].downcase.capitalize).new
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

    def run
      loop do
        if !update
          sleep Scoop[:poll_interval]
          next
        end
        run_build_tasks
        run_deploy_tasks
      end
    end

    # has there been an update in the repo we need to build for?
    def update
    end
    def email_results
    end

    #let's just do plain system for now and improve this later
    def exec(cmd)
      output << %x(cmd)
    end

    def run_build_tasks
      exec config[:build_tasks]
    end
    def run_deploy_tasks
      exec config[:deploy_tasks]
    end
  end
end
