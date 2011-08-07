module Scoop
  module Adapter
    class Base
      include Common

      def differ?
        local_revision != remote_revision
      end
      def local_revision
        raise "must implement for adapter"
      end
      def remote_revision
        raise "must implement for adapter"
      end
    end
  end
end
