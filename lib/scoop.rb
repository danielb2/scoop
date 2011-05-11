require 'scoop/builder'
require 'scoop/adapter/git' # TODO this should really be autoload. 
module Scoop
  @@options = {}
  class << self
    def []=(name,value)
      @@options[name.to_sym] = value
    end
    def [](name)
      @@options[name.to_sym]
    end
    def options
      @@options
    end
    def root
      Pathname.new File.realpath(File.join(File.dirname(__FILE__),'..'))
    end
    def create_config
      raise "not implemented"
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
      @logger ||= Scoop[:debug] ? Logger.new($stdout) : Logger.new(config[:logfile])
    end
  end
  self[:config_file] = (root + 'config/config.yml').to_s
  # self[:poll_interval] = 30
  self[:pidfile] = "/var/run/scoop.pid"
end
