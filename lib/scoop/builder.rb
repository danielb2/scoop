module Scoop
  class Builder
    include Common
    attr_accessor :output, :status, :adapter, :build_output, :deploy_output
    SUCCESS       = 1
    FAILED_BUILD  = 2
    FAILED_DEPLOY = 3

    def initialize(config)
      App.conf = config
      reset
      @adapter = App.adapter
    end

    def reset
      @status   = SUCCESS
      @output   = []
      @gist_url = nil
    end

    def prepare_build
      shell("rsync --delete -az #{config[:source_dir]}/ #{config[:build_dir]}")
      adapter.update_build
    end

    def run
      begin
        reset # reset all states
        debug "Checking for: #{config[:application]}"
        if !adapter.change?
          debug "no change found."
          sleep config[:poll_interval]
          exit if $term_received
          break if App.once == true
          next
        end
        debug "found update."
        if run_build_tasks
          if run_deploy_tasks
          end
        else
        end
        adapter.update_src if status == SUCCESS
        notify
        sleep config[:poll_interval]
      end while App.once != true
    end

    def debug(str)
      logger.debug str if Scoop[:debug]
    end

    # TODO: should extract this so custom notifies could also be made
    def notify
      return unless config[:notification].is_a? Array
      email_results if config[:notification].include? 'email'
      notify_jaconda if config[:notification].include? 'jaconda'
    end

    def gist_post
      return @gist_url if @gist_url
      abort "Please set gist.github_password instead of using gist.github_token in config file." if  config[:gist][:github_token]
      return unless config[:gist] and config[:gist][:github_user] and config[:gist][:github_password]

      ENV['GITHUB_USER'] = config[:gist][:github_user]
      ENV['GITHUB_PASSWORD'] = config[:gist][:github_password]
      @gist_url = Gist.write([{input: output_str, filename: 'scoop.txt', extension: 'txt'}], true)
    end

    def test_notify
      status = SUCCESS
      self.output = ['test notify']
      notify
    end

    def notify_jaconda
      Jaconda::Notification.authenticate(:subdomain => config[:jaconda][:subdomain],
                                         :room_id => config[:jaconda][:room_id],
                                         :room_token => config[:jaconda][:room_token])

      text= "(<b>#{config[:application]}</b>) [#{adapter.committer}]: deploy status: <i>#{status_map[status]}</i>"
      text += " (#{gist_post})" if gist_post
      Jaconda::Notification.notify(:text => text, :sender_name => "scoop")
    end

    def status_map
      {
        SUCCESS => 'Success',
        FAILED_BUILD => 'Failed Build',
        FAILED_DEPLOY => 'Failed Deploy',
      }
    end

    def email_subject
      subject = config[:email][:subject_prefix] + ' '
      case status
      when SUCCESS
        subject += 'SUCCESS: '
      when FAILED_BUILD
        subject += 'FAILED BUILD: '
      when FAILED_DEPLOY
        subject += 'FAILED DEPLOY: '
      else
        subject += 'UKNOWN FAILURE: '
      end
      return subject
      # note who made the latest build
      # trimmed last commit message in subject
    end

    def build_email
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
      mail.body gist_post ? gist_post : output
      return mail
    end

    def email_results
      return if App.no_mail
      build_email.deliver!
    end

    def header_output
      header = []
      header << ' --- Details '.ljust(80,'-')
      header << "/"
      header << "| Project: #{config[:application]}"
      header << "| Committer: #{adapter.committer}"
      header << "| Revision: #{adapter.revision}"
      header << "|"
    end

    def output_str
      (header_output + output).join("\n")
    end

    def run_build_tasks
      prepare_build
      output << '==== Build tasks '.ljust(80,'=')
      output << '= ' + config[:build_tasks]
      Dir.chdir(config[:build_dir]) do
        self.build_output = shell(config[:build_tasks])
      end
      output << self.build_output
      return true
      rescue ExecError => e
        logger.info "#{e.message}: build tasks failed".red
        self.status = FAILED_BUILD
        output << e.output
        return false
    end

    def run_deploy_tasks
      adapter.update_src
      output << '==== Deploy tasks '.ljust(80,'=')
      output << '= ' + config[:deploy_tasks]
      Dir.chdir(config[:source_dir]) do
        self.deploy_output = shell(config[:deploy_tasks])
      end
      output << self.deploy_output
      return true
      rescue ExecError => e
        logger.info "deploy tasks failed"
        self.status = FAILED_DEPLOY
        output << e.output
        return false
    end
  end
end
