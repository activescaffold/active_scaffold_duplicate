# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'active_scaffold_duplicate/version'

Gem::Specification.new do |s|
  s.name = %q{active_scaffold_duplicate}
  s.version = ActiveScaffoldDuplicate::Version::STRING

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sergio Cambra"]
  s.summary = %q{Clone record gem for Activescaffold}
  s.description = %q{Clone records using a method from model in ActiveScaffold}
  s.email = %q{activescaffold@googlegroups.com}
  s.homepage = %q{http://github.com/activescaffold/active_scaffold_duplicate}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.textile"
  ]
  s.files = Dir["{app,lib,config}/**/*"] + %w[LICENSE.txt README.textile]
  s.test_files = Dir["test/**/*"]
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]

  s.add_runtime_dependency(%q<active_scaffold>, [">= 3.7.1"])
end

