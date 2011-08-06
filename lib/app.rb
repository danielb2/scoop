class App
  cattr_accessor :logger, :cfg_file, :conf
  class << self
    def root
      File.realpath("#{File.dirname(__FILE__)}/..")
    end
    def load_conf(cfg_file)
      self.conf = YAML::load(File.open(cfg_file))
    end
    def stdout?
      return STDOUT if not ENV['DB_CONSOLE_LOG'].nil?
      false
    end
    def adapter
      @adapter ||= Scoop::Adapter.const_get(conf[:adapter].downcase.capitalize).new
    end
  end
end
