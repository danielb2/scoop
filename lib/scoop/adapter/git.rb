require_relative 'base'
module Scoop
  module Adapter
    class Git < Base
      def local_revision
      end
      def remote_revision
      end
      def last_committer
      end
      def update_cmd
        %|git pull #{Scoop.config[:git][:remote]} #{Scoop.config[:git][:branch]}|
      end
    end
  end
end
