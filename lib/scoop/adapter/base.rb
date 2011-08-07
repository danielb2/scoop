module Scoop
  module Adapter
    class Base
      include Common

      def differ?
        return true if App.force
        local_revision != remote_revision
      end
      alias :change? :differ?

      def local_revision
        raise "must implement for adapter"
      end
      def remote_revision
        raise "must implement for adapter"
      end
    end
  end
end
