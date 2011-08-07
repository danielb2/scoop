require_relative 'base'
module Scoop
  module Adapter
    class Git < Base
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

      def commit_revision
        cmd = %{git log | head -1 | cut -d ' ' -f 2}
        exit_status, result = exec(cmd)
      end
      def remote_revision
        Dir.chdir config[:source_dir] do
          cmd = %(git ls-remote #{config[:git][:remote]} #{config[:git][:branch]} | awk '{print $1}')
          exec(cmd)
        end
      end
      def local_revision
        Dir.chdir config[:source_dir] do
          # cmd = %{git show HEAD --pretty='%H' | head -1}
          # cmd = %{git rev-list HEAD | head -1}
          cmd = %{git rev-list HEAD --max-count 1}
          exit_status, result = exec(cmd)
        end
      end

      def change?
        Dir.chdir config[:source_dir] do
          cmd = %{git fetch #{config[:git][:remote]} #{config[:git][:branch]} && git rev-parse --verify HEAD}
          exit_status, result = exec(cmd)
          current_rev, remote_rev = result.split("\n")
          debug "current: #{current_rev} remote: #{remote_rev} last_tried: #{@last_tried_rev}"
          return false if current_rev == remote_rev
          return false if remote_rev == @last_tried_rev
          @last_tried_rev = remote_rev
        end
        return true
      end

      def update_cmd
        %|git pull #{config[:git][:remote]} #{config[:git][:branch]}|
      end
    end
  end
end
