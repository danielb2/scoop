require_relative 'base'
module Scoop
  module Adapter
    class Git < Base
      def committer_cmd
        %{git log --format="%cn" | head -1}
      end
      def revision_cmd
        %{git log --format="%h" | head -1}
      end
      def update_build
        super
        Dir.chdir config[:build_dir] do
          result = shell(update_cmd)
          self.committer = shell(committer_cmd).chomp
          self.revision = shell(revision_cmd).chomp
          return false if result =~ /up-to-date./
        end
        return true
      end
      def update_src
        super
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
          cmd = %(git ls-remote #{config[:git][:remote]} #{config[:git][:branch]} | awk '{print $1}' | head -1)
          shell(cmd).chomp
        end
      end
      def local_revision
        Dir.chdir config[:source_dir] do
          # cmd = %{git show HEAD --pretty='%H' | head -1}
          # cmd = %{git rev-list HEAD | head -1}
          cmd = %{git rev-list HEAD --max-count 1}
          shell(cmd).chomp
        end
      end

      def update_cmd
        cmd = ''
        cmd += %|git reset --hard && | if config[:git][:reset_local] == true
        cmd += %|git pull #{config[:git][:remote]} #{config[:git][:branch]}|
        cmd += %|&& git co #{config[:git][:branch]}|
      end
    end
  end
end
