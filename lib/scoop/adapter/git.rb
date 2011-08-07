require_relative 'base'
module Scoop
  module Adapter
    class Git < Base
      def last_committer
      end
      def update_build
        logger.info 'updating build'
        Dir.chdir config[:build_dir] do
          result = shell(update_cmd)
          return false if result =~ /up-to-date./
        end
        return true
      end
      def update_src
        logger.info 'updating source'
        Dir.chdir config[:source_dir] do
          result = shell(update_cmd)
        end
      end

      def commit_revision
        cmd = %{git log | head -1 | cut -d ' ' -f 2}
        exit_status, result = shell(cmd)
      end
      def remote_revision
        Dir.chdir config[:source_dir] do
          cmd = %(git ls-remote #{config[:git][:remote]} #{config[:git][:branch]} | awk '{print $1}')
          shell(cmd)
        end
      end
      def local_revision
        Dir.chdir config[:source_dir] do
          # cmd = %{git show HEAD --pretty='%H' | head -1}
          # cmd = %{git rev-list HEAD | head -1}
          cmd = %{git rev-list HEAD --max-count 1}
          shell(cmd)
        end
      end

      def update_cmd
        %|git pull #{config[:git][:remote]} #{config[:git][:branch]}|
      end
    end
  end
end
