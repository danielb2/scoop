require 'simplecov'
SimpleCov.start do
  add_filter do |source_file|
    source_file.filename =~ /spec/
  end
end
require 'scoop'
require "rspec/mocks/standalone"
require 'pry'
require 'fileutils'
Scoop::App.silent = true

def conf
  root = Scoop.root
  config_file = (Scoop.root + 'config/config.yml.sample').to_s
  conf = YAML::load(ERB.new( IO.read( config_file ) ).result(binding) )
  conf[:poll_interval] = 0.01
  conf[:git][:reset_local] = false # we reset scoop changes otherwise.
  conf
end

def clean_tmp
  FileUtils.rm_rf Scoop::App.root + '/spec/tmp'
end
