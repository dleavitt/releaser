# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'releaser/version'

Gem::Specification.new do |spec|
  spec.name          = "jira_release"
  spec.version       = Releaser::VERSION
  spec.authors       = ["Daniel Leavitt"]
  spec.email         = ["daniel.leavitt@gmail.com"]
  spec.summary       = "Script for generating changelogs with JIRA tickets"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rugged"
  spec.add_dependency "thor"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
