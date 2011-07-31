require 'bundler'
require 'rspec/core/rake_task'
Bundler::GemHelper.install_tasks

desc "get us into console"
task :console do
  puts "Check http://vimeo.com/26391171 for usage"
  system("bundle exec pry -I lib -r environment -r awesome_print")
end

desc "get us into test console"
task :testconsole do
  puts "Check http://vimeo.com/26391171 for usage"
  system("bundle exec pry -I lib -I spec -r environment -r awesome_print -r spec_helper")
end

RSpec::Core::RakeTask.new(:spec)
