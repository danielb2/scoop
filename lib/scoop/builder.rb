module Scoop
  class Builder
    def config
      root = Scoop.root
      YAML::load(ERB.new( IO.read( config_file ) ).result(binding) )
    end

    def config_file
      get :config_file || YAML.load_file((Scoop.root + 'config/config.yml').to_s)
    end

    def run
      run_build_tasks
      run_deploy_tasks
    end
  end
end
