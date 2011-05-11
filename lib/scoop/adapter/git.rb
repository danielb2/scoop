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
      def update_build
        logger.info 'updating build'
        Dir.chdir config[:build_dir] do
          # exec("rsync -az --delete #{config[:source_dir]}/ #{config[:build_dir]}")
          exit_status, result = exec(update_cmd)
          return false if result =~ /up-to-date./
        end
        return true
      end
      def update_src
        logger.info 'updating source'
        Dir.chdir config[:source_dir] do
          exit_status, result = exec(update_cmd)
        end
      end

      def update_cmd
        %|git pull #{config[:git][:remote]} #{config[:git][:branch]}|
      end
    end
  end
end
