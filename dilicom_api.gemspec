# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dilicom_api/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Éric Daspet"]
  gem.email         = ["eric.daspet@survol.fr"]
  gem.description   = %q{Client library for Dilicom hub API}
  gem.summary       = %q{Client library for Dilicom hub API}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "dilicom_api"
  gem.require_paths = ["lib"]
  gem.version       = DilicomApi::VERSION


  gem.add_dependency 'faraday'
  gem.add_dependency 'faraday_middleware'
  gem.add_dependency 'activesupport', '>= 4.0.0'
  gem.add_dependency 'i18n'
  gem.add_dependency 'tzinfo'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'faraday_simulation'
  gem.add_development_dependency 'gem-release'

  gem.required_ruby_version = '>= 2.0.0'
end
