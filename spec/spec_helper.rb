require 'bundler'
Bundler.setup
require 'environment'
require 'awesome_print'
require "rspec/mocks/standalone"
require 'pry'
require 'fileutils'

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
