module Scoop
  module Adapter
    class Base
      include Common
      attr_accessor :last_tried
      attr_accessor :committer, :revision
      def initialize
        @committer = 'unknown'
        @revision  = 'unknown'
      end

      def differ?
        return true if App.force
        @remote_revision = remote_revision
        debug "last_tried: #{@last_tried[0..6] if @last_tried} remote: #{@remote_revision[0..6]}"
        return false if @remote_revision == @last_tried
        return false if @remote_revision.nil? or @remote_revision.empty?
        @last_tried = @remote_revision
        local_revision != @remote_revision
      end
      alias :change? :differ?

      def local_revision
        raise "must implement for adapter"
      end
      def remote_revision
        raise "must implement for adapter"
      end
      def update_build
        logger.info 'updating build'
        @committer = 'unknown'
        @revision = 'unknown'
      end
      def update_src
        logger.info 'updating source'
      end
    end
  end
end
