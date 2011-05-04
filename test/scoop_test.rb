require './test/helper'

describe Scoop do
  it "load config correct" do
    scoop = Scoop::Builder.new
    scoop.config[:source_dir].must_equal File.join(File.dirname(File.realpath(__FILE__)),'src')
  end
end
