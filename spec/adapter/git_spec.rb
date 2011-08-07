require File.dirname(__FILE__) + '/../spec_helper'



module GitSpecHelper
  extend self

  def origin_dir
    App.root + '/spec/tmp/origin'
  end
  def src_dir
    App.root + '/spec/tmp/src'
  end
  def build_dir
    App.root + '/spec/tmp/build'
  end
  def init_git
    init_git_origin
    init_git_source
  end

  def init_git_origin
    FileUtils.mkdir_p origin_dir
    Dir.chdir origin_dir do
      exec "git init"
      exec "date > file.txt"
      exec "git add file.txt"
      exec "git commit -m 'first file'"
    end
  end

  def init_git_source
    dir = App.root + '/spec/tmp'
    Dir.chdir dir do
      exec "git clone #{origin_dir} #{src_dir}"
    end
  end
  def mod_git_origin
    Dir.chdir origin_dir do
      exec "ls > file.txt"
      exec "git commit -a -m 'second commit'"
    end
  end
end
  def exec(cmd)
    `#{cmd}`
    return
    puts "==> #{cmd}"
    puts `#{cmd}`.split("\n").map { |l| ' +' + l }
  end

describe Scoop::Adapter::Git do
  before do
    clean_tmp
    GitSpecHelper.init_git
  end
  it "should not detect change for new clone" do
    adapter = Scoop::Adapter::Git.new
    config = conf.update source_dir: GitSpecHelper.src_dir
    adapter.stub(:config) { config }
    adapter.differ?.should == false
  end
  it "should detect change" do
    adapter = Scoop::Adapter::Git.new
    config = conf.update source_dir: GitSpecHelper.src_dir
    GitSpecHelper.mod_git_origin
    adapter.stub(:config) { config }
    adapter.differ?.should == true
  end
  context "#update_build" do
    it "should not have updated build dir" do
      adapter = Scoop::Adapter::Git.new
      config = conf.merge source_dir: GitSpecHelper.src_dir
      adapter.stub(:config) { config }
      exec("rsync --delete -az #{config[:source_dir]}/ #{config[:build_dir]}")
      adapter.update_build.should == false
    end
    it "should update build dir" do
      adapter = Scoop::Adapter::Git.new
      config = conf.merge source_dir: GitSpecHelper.src_dir
      config[:build_dir] = GitSpecHelper.build_dir
      GitSpecHelper.mod_git_origin
      adapter.stub(:config) { config }
      cmd = "rsync --delete -az #{config[:source_dir]}/ #{config[:build_dir]}"
      system cmd
      adapter.update_build.should == true
    end
  end
end
