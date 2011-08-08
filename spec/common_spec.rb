require File.dirname(__FILE__) + '/spec_helper'

describe Scoop::Common do
  include Scoop::Common
  before do
  end
  it "should output stderr fine when using shell command" do
    begin
      shell("missing scoop").should == 'blah'
    rescue Exception => e
      e.output.should == "sh: missing: command not found\n"
    end
  end
end
