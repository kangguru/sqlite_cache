# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sqlite_cache/version'

Gem::Specification.new do |spec|
  spec.name          = "sqlite_cache"
  spec.version       = SqliteCache::VERSION
  spec.authors       = ["Lars Brillert"]
  spec.email         = ["lars@railslove.com"]
  spec.description   = %q{Use sqlite3 as a caching adapter}
  spec.summary       = %q{Use sqlite3 as a caching adapter}
  spec.homepage      = "http://railslove.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_dependency "sequel"
  spec.add_dependency "activesupport"
  spec.add_dependency "sqlite3"
  spec.add_dependency "dalli"
end
