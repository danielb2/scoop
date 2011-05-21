require './test/helper'

describe Scoop do
  attr_accessor :builder
  before do
    @builder = Scoop::Builder.new
  end
  it "load config correct" do
    builder.config[:source_dir].must_equal File.join(File.dirname(File.realpath(__FILE__)),'src')
  end
  it "should run build tasks correct" do
    builder.run_deploy_tasks
  end
  it "should run deploy tasks correct" do
  end
  it "should send success email on success" do
  end
  it "should send fail email on build fail" do
  end
  it "should send fail email on deploy fail" do
  end
end
