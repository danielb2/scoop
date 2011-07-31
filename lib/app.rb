class App
  cattr_accessor :logger, :cfg_file, :conf
  class << self
    def root
      File.realpath("#{File.dirname(__FILE__)}/..")
    end
    def load_conf
      self.conf = YAML::load(File.open(File.join(self.root, 'config', 'app.yml')))
    end
    def stdout?
      return STDOUT if not ENV['DB_CONSOLE_LOG'].nil?
      false
    end
  end
end
