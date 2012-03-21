require File.dirname(__FILE__) + '/spec_helper'

describe Scoop do
  before do
    Mail::Message.any_instance.stub(:deliver!) {nil}
    Scoop::App.once = true
  end
  let(:builder) { Scoop::Builder.new(conf) }
  it "load config correct" do
    pending
    class Foo
      include Scoop::Common
    end
    Foo.new.config[:source_dir].must_equal File.join(File.dirname(File.realpath(__FILE__)),'src')
  end
  it "should send success email on success" do
    pending
  end
  it "should send fail email on build fail" do
    pending
  end
  it "should send fail email on deploy fail" do
    pending
  end
  it "should not include gist link if gist auth fails" do
  end
  it "should include output in body and warning abotu gist failing if gist fails"
  it "should send fail if version control to pull fails" do
    pending
    # example, do git pull origin nonexistentrepo
  end
  it "should execute build tasks in build dir" do
    pending
  end
  it "should execute deploy tasks in deploy dir" do
    pending
  end
  let (:base_adapter) do
    o = Object.new
    def o.change?
      true
    end
    def o.update_build
    end
    def o.update_src
    end
    o
  end
  it "should run build tasks on adapter notification of repo change" do
    pending
    builder = Scoop::Builder.new(conf)
    builder.adapter = base_adapter
    builder.run
    builder.expects(:run_build_tasks).unce
  end
  it "shouldn't do anything if there's no change" do
    adapter = base_adapter
    def adapter.change?
      false
    end
    builder.adapter = base_adapter
    builder.should_receive(:run_build_tasks).never
    builder.run
  end
  it "shouldn't run deploy tasks if build_tasks failed" do
    cfg = conf
    cfg[:build_tasks] = 'ls /sdocksd'
    builder = Scoop::Builder.new(cfg)
    FileUtils.mkdir_p conf[:build_dir]
    FileUtils.mkdir_p conf[:source_dir]
    builder.adapter = base_adapter
    builder.should_receive(:run_build_tasks).once
    builder.should_receive(:run_deploy_tasks).never
    builder.run
  end
  it "should run deploy tasks on successful build" do
    cfg = conf
    cfg[:deploy_tasks] = 'echo fun'
    Scoop::Adapter::Git.any_instance.stub(:change?) { true }
    builder = Scoop::Builder.new(cfg)
    builder.stub(:run_build_tasks) { true }
    builder.stub(:update_src) {nil}
    builder.stub(:email_results) {nil}
    builder.run
    builder.deploy_output.should == "fun\n"
  end
  it "should not retry a build. if it fails, stop trying until it passes" do
    class Scoop::Adapter::Mock < Scoop::Adapter::Base
      def local_revision
      'abc'
      end
      def remote_revision
      'ccd'
      end
    end
    adapter = Scoop::Adapter::Mock.new
    adapter.differ?.should == true
    adapter.differ?.should == false
    def adapter.remote_revision
      'qqq'
    end
    adapter.differ?.should == true
  end
  it "should not pull from source again when the deploy tasks are done"
  it "should retry after X seconds if the failure is connection issue with repo"
  it "should not use gist if gist is not all filled in from template"
end
