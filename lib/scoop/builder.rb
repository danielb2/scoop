module Scoop
  class Builder
    include Common
    attr_accessor :output, :status
    SUCCESS       = 1
    FAILED_BUILD  = 2
    FAILED_DEPLOY = 3

    def initialize(config)
      reset
    end

    def version_control
      @version_control ||= Scoop::Adapter.const_get(config[:adapter].downcase.capitalize).new
      rescue NameError
        nil
    end

    def reset
      @status = SUCCESS
      @output = ''
    end

    def prepare_build
      exec("rsync --delete -az #{config[:source_dir]}/ #{config[:build_dir]}")
      version_control.update_build
    end

    def run
      loop do
        reset # reset all states
        if !version_control.change?
          debug "no change found."
          sleep config[:poll_interval]
          exit if $term_received
          next
        end
        debug "found update."
        if run_build_tasks
          if run_deploy_tasks
          end
        else
        end
        version_control.update_src if status == SUCCESS
        email_results
        sleep 1 # we don't want to eat cpu incase the update is wonky
      end
    end

    def debug(str)
      logger.debug str if Scoop[:debug]
    end

    def email_subject
      subject = ''
      case status
      when SUCCESS
        subject = 'SUCCESS: '
      when FAILED_BUILD
        subject = 'FAILED BUILD: '
      when FAILED_DEPLOY
        subject = 'FAILED DEPLOY: '
      else
        subject = 'UKNOWN FAILURE: '
      end
      return subject
      # note who made the latest build
      # trimmed last commit message in subject
    end

    def email_results
      debug 'skipping email'
      return nil
      debug "emailing results"

      settings = config[:email]
      smtp     = settings[:smtp]

      args = [smtp[:host], smtp[:port], smtp[:account],
        smtp[:password], smtp[:authentication]]
      smtp_conn = Net::SMTP.new(smtp[:host], smtp[:port])
      smtp_conn.enable_starttls
      smtp_conn.start(smtp[:host], smtp[:account], smtp[:password], smtp[:authentication])
      Mail.defaults do
        delivery_method :smtp_connection, { :connection => smtp_conn }
      end
      mail = Mail.new
      mail.to settings[:to]
      mail.from settings[:from]
      mail.subject email_subject
      mail.body output
      mail.deliver!
      debug "email sent"
    end
    def run_build_tasks
      prepare_build
      exit_status, result = nil
      Dir.chdir(config[:build_dir]) do
        exit_status, result = exec(config[:build_tasks])
      end
      output << '==== Build tasks '.ljust(80,'=') + "\n"
      output << '= ' + config[:build_tasks] + "\n"
      output << result
      output << ''.ljust(80,'=') + "\n"
      if exit_status != 0
        logger.info "build tasks failed"
        self.status = FAILED_BUILD
        return false
      end
      return true
    end

    def run_deploy_tasks
      version_control.update_src
      exit_status, result = nil
      Dir.chdir(config[:source_dir]) do
        exit_status, result = exec(config[:deploy_tasks])
      end
      output << result
      if exit_status != 0
        logger.info "deploy tasks failed"
        self.status = FAILED_DEPLOY
      end
    end
  end
end
