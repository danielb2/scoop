module Scoop
  class Builder
    def config
      root = Scoop.root
      YAML::load(ERB.new( IO.read( config_file ) ).result(binding) )
    end

    def config_file
      self[:config_file] || YAML.load_file((Scoop.root + 'config/config.yml').to_s)
    end

    def run
      loop do
        if !update
          sleep Sleep[:check_interval]
          next
        end
        poll_for_update
        run_build_tasks
        run_deploy_tasks
        email_results
      end
    end
    def email_results
    end

    def run_build_tasks
    end
    def run_deploy_tasks
    end
  end
end
