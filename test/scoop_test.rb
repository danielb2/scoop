require './test/helper'

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
  it "should run deploy tasks correct" do
  end
  it "should send success email on success" do
  end
  it "should send fail email on build fail" do
  end
  it "should send fail email on deploy fail" do
  end
  it "should send fail if version control to pull fails" do
    # example, do git pull origin nonexistentrepo
  end
  it "should execute build tasks in build dir" do
  end
  it "should execute deploy tasks in deploy dir" do
  end
end
