require File.dirname(__FILE__) + '/spec_helper'

describe Scoop::Builder do
  before do
    Mail::Message.any_instance.stub(:deliver!) {nil}
  end
  let(:builder) { Scoop::Builder.new(conf) }
  context "#run_build_tasks" do
    it "should run build tasks correct" do
      builder.run_build_tasks
      builder.build_output.should == "my build tasks\n"
    end
    it "should have right header output" do
      builder.run_build_tasks
      builder.output_str.should =~ /Project: Scoop/
    end
    it "should have the right status" do
      builder.run_build_tasks
      builder.status.should == Scoop::Builder::SUCCESS
    end
    it "should have failed build status on fail" do
      builder = Scoop::Builder.new(conf.merge(:build_tasks => 'ls sodncosdc'))
      builder.run_build_tasks
      builder.status.should == Scoop::Builder::FAILED_BUILD
    end
  end

  context "#run_deploy_tasks" do
    it "should run deploy tasks correct" do
      builder.run_deploy_tasks
      builder.deploy_output.should == "deploy\n"
    end
    it "should have the right status" do
      builder.run_deploy_tasks
      builder.status.should == Scoop::Builder::SUCCESS
    end
    it "should have failed deploy status on fail" do
      builder = Scoop::Builder.new(conf.merge(:deploy_tasks => 'ls sodncosdc'))
      builder.run_deploy_tasks
      builder.status.should == Scoop::Builder::FAILED_DEPLOY
    end
  end
end
