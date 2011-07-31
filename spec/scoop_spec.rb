require File.dirname(__FILE__) + '/spec_helper'

def conf
  root = Scoop.root
  config_file = (Scoop.root + 'config/config.yml.sample').to_s
  conf = YAML::load(ERB.new( IO.read( config_file ) ).result(binding) )
  conf
end

describe Scoop do
  attr_accessor :builder
  before do
    @builder = Scoop::Builder.new
  end
  it "load config correct" do
    pending
    class Foo
      include Scoop::Common
    end
    Foo.new.config[:source_dir].must_equal File.join(File.dirname(File.realpath(__FILE__)),'src')
  end
  it "should run build tasks correct" do
    builder = Scoop::Builder.new
    builder.stubs(:config).returns(conf)
    ap builder.config
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
  it "should run build tasks on adapter notification of repo change"
  it "should run deploy tasks on successful build"
end
