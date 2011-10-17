require 'simplecov'
SimpleCov.start do
  add_filter do |source_file|
    source_file.filename =~ /spec/
  end
end
require 'environment'
require 'awesome_print'
require "rspec/mocks/standalone"
require 'pry'
require 'fileutils'
App.silent = true

def conf
  root = Scoop.root
  config_file = (Scoop.root + 'config/config.yml.sample').to_s
  conf = YAML::load(ERB.new( IO.read( config_file ) ).result(binding) )
  conf[:poll_interval] = 0.01
  conf
end

def clean_tmp
  FileUtils.rm_rf App.root + '/spec/tmp'
end
