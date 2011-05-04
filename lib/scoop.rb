module Scoop
  # Your code goes here...
  class Builder
    def config
      YAML.load_file((Scoop.root + 'config/config.yml').to_s)
      root = Scoop.root
      YAML::load(ERB.new( IO.read( (Scoop.root+'config/config.yml').to_s ) ).result(binding) )
    end

    def run
      run_build_tasks
      run_deploy_tasks
    end
  end

  def self.root
    Pathname.new File.realpath(File.join(File.dirname(__FILE__),'..'))
  end
end
