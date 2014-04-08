# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'saferpay/version'

Gem::Specification.new do |s|
  s.name        = 'saferpay'
  s.version     = Saferpay::VERSION
  s.authors     = ['Pedro Gaspar', 'Whitesmith']
  s.email       = ['me@pedrogaspar.com', 'info@whitesmith.co']
  s.licenses    = 'MIT'

  s.summary     = 'A Ruby Saferpay API wrapper'
  s.description = 'Interact with Saferpay\'s HTTPS Interface with an object-oriented API wrapper built with HTTParty.'
  s.homepage    = 'http://github.com/whitesmith/saferpay-gem'
  
  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 1.9.3'  # Due to HTTParty

  s.add_dependency 'httparty', '~> 0.12'

  s.add_development_dependency 'bundler', '~> 1.5'
  s.add_development_dependency 'rake',    '~> 0'
  s.add_development_dependency 'rspec',   '~> 2.14.1'
  s.add_development_dependency 'webmock', '1.15.2'
  s.add_development_dependency 'vcr',     '~> 2.8'
end
