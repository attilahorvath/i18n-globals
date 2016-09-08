# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'i18n/globals/version'

Gem::Specification.new do |spec|
  spec.name          = 'i18n-globals'
  spec.version       = I18n::Globals::VERSION
  spec.authors       = ['Attila Horvath']
  spec.email         = ['hun.ati500@gmail.com']
  spec.summary       = %q{ Adds support for I18n global variables, which will be available for interpolation into every translation.}
  spec.description   = %q{ Extends the Ruby I18n gem with global variables. The globals will be available for interpolation in every translation without explicitly specifying them in a call to I18n.translate. The variables can be accessed through I18n.config.globals.}
  spec.homepage      = 'https://github.com/attilahorvath/i18n-globals'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'

  spec.add_runtime_dependency 'i18n'
end
