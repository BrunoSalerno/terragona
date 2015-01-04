# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'terragona/version'

Gem::Specification.new do |spec|
  spec.name          = "terragona"
  spec.version       = Terragona::VERSION
  spec.authors       = ["Bruno Salerno"]
  spec.email         = ["br.salerno@gmail.com"]
  spec.description   = %q{Create polygons for geonames places}
  spec.summary       = %q{Use API or dumps as input, draw polygons, and store them in a Postgres/Postgis db}
  spec.homepage      = "https://github.com/BrunoSalerno/terragona"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "pg"
  spec.add_runtime_dependency "sequel", "~> 3.48.0"
  spec.add_runtime_dependency "httpi", "~> 1.1.0"
  spec.add_runtime_dependency "diskcached"
  spec.add_runtime_dependency "similar_text", "~> 0.0.4"
  spec.add_runtime_dependency "geokit"
  
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry-debugger"
end
