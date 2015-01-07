# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'doyoubuzz/showcase/version'

Gem::Specification.new do |spec|
  spec.name          = "doyoubuzz-showcase"
  spec.version       = Doyoubuzz::VERSION
  spec.authors       = ["David RUYER"]
  spec.email         = ["david.ruyer@gmail.com"]
  spec.description   = %q{Wrapper around the DoYouBuzz showcase API}
  spec.summary       = %q{Wrapper around the DoYouBuzz showcase API}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "httparty", "~> 0.13"
  spec.add_dependency "hashie", "~> 3.3"
end
