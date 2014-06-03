# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'soft_delete_rails/version'

Gem::Specification.new do |spec|
  spec.name          = 'soft_delete_rails'
  spec.version       = SoftDeleteRails::VERSION
  spec.authors       = ['Andrew Medeiros']
  spec.email         = ['amedeiros0920@gmail.com']
  spec.summary       = %q{Soft delete records within rails}
  spec.description   = %q{Soft delete records within rails}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'activerecord', '4.1.0'
end
