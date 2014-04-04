Gem::Specification.new do |s|
  s.name        = 'saferpay'
  s.version     = '0.0.0'
  s.authors     = ['Pedro Gaspar', 'Whitesmith']
  s.email       = ['me@pedrogaspar.com', 'info@whitesmith.co']
  s.licenses    = 'MIT'

  s.summary     = 'A Ruby Saferpay API wrapper'
  s.description = 'Interact with Saferpay\'s HTTPS Interface with an object-oriented API wrapper built with HTTParty.'
  s.homepage    = 'http://github.com/whitesmith/saferpay-gem'
  
  s.files       = Dir.glob("lib/**/*.rb")

  s.add_dependency 'httparty', '~> 0.12'
  s.add_development_dependency 'rspec', '~> 2.14'
  s.add_development_dependency 'webmock', '~> 1.15'
  s.add_development_dependency 'vcr', '~> 2.8'
end
