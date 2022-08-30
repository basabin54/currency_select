# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'currency_select/version'

Gem::Specification.new do |s|
  s.name        = 'currency_select'
  s.version     = CurrencySelect::VERSION
  s.licenses    = ['MIT']
  s.authors     = ['Brook Sabin']
  s.email       = ['basabin54@gmail.com']
  s.homepage    = 'https://github.com/basabin54/currency_select'
  s.summary     = %q{Currency Select Plugin}
  s.description = %q{Provides a simple helper to get an HTML select list of currencies.}

  s.metadata      = { 'bug_tracker_uri' => 'https://github.com/basabin54/currency_select/issues',
                      'changelog_uri' =>  'https://github.com/basabin54/currency_select/blob/master/CHANGELOG.md',
                      'source_code_uri' =>  'https://github.com/basabin54/currency_select' }

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.7'

  s.add_development_dependency 'actionpack', '~> 7.0'
  # s.add_development_dependency 'pry', '~> 0'
  s.add_development_dependency 'rake', '~> 13'
  # s.add_development_dependency 'rspec', '~> 3'

  s.add_dependency 'money', '~> 6.0'
end
