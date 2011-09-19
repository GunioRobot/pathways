# -*- encoding: utf-8 -*-
require File.expand_path("../lib/pathways/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "pathways"
  s.version     = Pathways::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mint Digital","Simon Reed"]
  s.email       = ["hello@mintdigital.com","min.sucks@gmail.com"]
  s.homepage    = "http://github.com/simonreed/pathways"
  s.summary     = "Helps your track the pathways in your Rails app."
  s.description = "Helps your track the pathways in your app so that you can pave the cowpaths. Uses MongoDB to traverse the paths looking for little nuggets."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "pathways"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_dependency "mongo_mapper",    "0.8.6"
  s.add_dependency "vegas",           "~> 0.1.2"
  s.add_dependency "sinatra",         ">= 0.9.2"
  s.add_dependency "bson_ext"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
