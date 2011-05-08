module Scoop
  module Adapter
    class Base
      attr_accessor :logger,:config
      def initialize(config,logger)
        @logger = logger
        @config = config
      end
    end
  end
end
