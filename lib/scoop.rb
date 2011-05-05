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
    end
  end
  self[:config_file] = (root + 'config/config.yml').to_s
end
