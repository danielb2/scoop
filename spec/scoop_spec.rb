require File.dirname(__FILE__) + '/spec_helper'

describe Scoop do
  attr_accessor :builder
  before do
    @builder = Scoop::Builder.new(conf)
  end
  it "load config correct" do
    pending
    class Foo
      include Scoop::Common
    end
    Foo.new.config[:source_dir].must_equal File.join(File.dirname(File.realpath(__FILE__)),'src')
  end
  it "should run build tasks correct" do
    builder = Scoop::Builder.new(conf)
    builder.run_build_tasks
    builder.build_output.should == "my build tasks\n"
  end
  it "should run deploy tasks correct" do
    builder = Scoop::Builder.new(conf)
    builder.run_deploy_tasks
    builder.deploy_output.should == "deploy\n"
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
    builder.expects(:run_build_tasks).once
  end
  it "shouldn't do anything if there's no change" do
    builder = Scoop::Builder.new(conf)
    adapter = base_adapter
    def adapter.change?
      false
    end
    builder.adapter = base_adapter
    builder.should_receive(:run_build_tasks).never
    builder.run once: true
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
    builder.run once: true
  end
  it "should run deploy tasks on successful build" do
    cfg = conf
    cfg[:deploy_tasks] = 'echo fun'
    Scoop::Adapter::Git.any_instance.stub(:change?) { true }
    builder = Scoop::Builder.new(cfg)
    builder.stub(:run_build_tasks) { true }
    builder.stub(:update_src) {nil}
    builder.stub(:update_src) {email_results}
    builder.run once: true
    builder.deploy_output.should == "fun\n"
  end
end
