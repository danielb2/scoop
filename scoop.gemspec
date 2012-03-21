# -*- encoding: utf-8 -*-
require File.expand_path("../lib/scoop/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "scoop"
  s.version     = Scoop::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Daniel Bretoi']
  s.email       = ['daniel@bretoi.com']
  s.homepage    = "https://github.com/danielb2/scoop"
  s.summary     = "A small, easy deployment tool."
  s.description = "A small easy continous deployment tool. You commit, it deploys."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "scoop"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_dependency "mail"
  s.add_dependency "cattr"
  s.add_dependency "awesome_print"
  s.add_dependency "jaconda"
  s.add_dependency "gist"
  s.add_dependency "pastie-api"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
