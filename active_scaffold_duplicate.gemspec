# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'active_scaffold_duplicate/version'

Gem::Specification.new do |s|
  s.name = 'active_scaffold_duplicate'
  s.version = ActiveScaffoldDuplicate::Version::STRING

  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.authors = ['Sergio Cambra']
  s.summary = 'Clone record gem for Activescaffold'
  s.description = 'Clone records using a method from model in ActiveScaffold'
  s.email = 'activescaffold@googlegroups.com'
  s.homepage = 'http://github.com/activescaffold/active_scaffold_duplicate'
  s.extra_rdoc_files = [
    'LICENSE.txt',
    'README.md'
  ]
  s.files = Dir['{app,lib,config}/**/*'] + %w[LICENSE.txt README.md]
  s.licenses = ['MIT']
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 3.2'

  s.add_dependency('active_scaffold', ['>= 4.4.5'])
  s.metadata['rubygems_mfa_required'] = 'true'
end
