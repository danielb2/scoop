module Scoop
  class Builder
    include Common
    attr_accessor :output, :status
    SUCCESS       = 1
    FAILED_BUILD  = 2
    FAILED_DEPLOY = 3

    def initialize
      FileUtils.mkdir_p config[:build_dir]
    end

    def version_control
      Scoop::Adapter.const_get(config[:adapter].downcase.capitalize).new
      rescue NameError
        nil
    end

    def reset
      @status = SUCCESS
      @output = ''
    end

    def run
      loop do
        reset # reset all states
        if !version_control.update_build
          debug "no update found."
          sleep config[:poll_interval]
          next
        end
        debug "found update."
        if run_build_tasks
          if run_deploy_tasks
          end
        else
        end
        update_src if status == SUCCESS
        email_results
        sleep 1 # we don't want to eat cpu incase the update is wonky
      end
    end

    def update_src
    end

    def debug(str)
      logger.debug str if Scoop[:debug]
    end

    def email_subject
      subject = status == SUCCESS ? 'SUCCESS: ' : 'FAILED: '
      return subject
      # note who made the latest build
      # trimmed last commit message in subject
    end

    def email_results
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
      mail.body 'testing sendmail' + output
      mail.deliver!
      debug "email sent"
    end
    def run_build_tasks
      exit_status, result = exec(config[:build_tasks])
      output << result
      if exit_status != 0
        logger.info "build tasks failed"
        self.status = FAILED_BUILD
        return false
      end
      return true
    end

    def run_deploy_tasks
      exit_status, result = exec(config[:deploy_tasks])
      output << result
      if exit_status != 0
        logger.info "deploy tasks failed"
        self.status = FAILED_DEPLOY
      end
    end
  end
end
