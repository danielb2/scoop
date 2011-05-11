module Scoop
  class Builder
    attr_accessor :output, :config, :exec_status, :status
    SUCCESS       = 1
    FAILED_BUILD  = 2
    FAILED_DEPLOY = 3

    def initialize
      @output = StringIO.new
      @status = SUCCESS
      FileUtils.mkdir_p Scoop.config[:build_dir]
    end

    #version 
    def version_control
      Scoop::Adapter.const_get(Scoop.config[:adapter].downcase.capitalize).new
      rescue NameError
        nil
    end


    def run
      loop do
        if !update?
          debug "no update found."
          sleep Scoop.config[:poll_interval]
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
    def update?
      Dir.chdir Scoop.config[:build_dir] do
        Scoop.exec("rsync -az --delete #{Scoop.config[:source_dir]}/ #{Scoop.config[:build_dir]}")
        exit_status, result = Scoop.exec(version_control.update_cmd)
        return false if result =~ /up-to-date./
      end
      return true
    end


    def debug(str)
      Scoop.logger.debug str if Scoop[:debug]
    end

    def email_subject
      subject = status == SUCCESS ? 'SUCCESS: ' : 'FAILED: '
      return subject
      # note who made the latest build
      # trimmed last commit message in subject
    end

    def email_results
      debug "emailing results"

      settings = Scoop.config[:email]
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
      mail.body 'testing sendmail'
      mail.deliver!
      debug "email sent"
    end
    def run_build_tasks
      exit_status, result = Scoop.exec(Scoop.config[:build_tasks])
      output << result
      if exec_status != 0
        Scoop.logger.info "build tasks failed"
        self.status = FAILED_BUILD
        return false
      end
      return true
    end

    def run_deploy_tasks
      exit_status, result = Scoop.exec(Scoop.config[:deploy_tasks])
      if exec_status != 0
        Scoop.logger.info "deploy tasks failed"
        self.status = FAILED_DEPLOY
      end
    end
  end
end
