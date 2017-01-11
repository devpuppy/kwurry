# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kwurry/version'

Gem::Specification.new do |spec|
  spec.name          = "kwurry"
  spec.version       = Kwurry::VERSION
  spec.authors       = ["Justin Jones"]

  spec.summary       = %q{curry kwargs with Proc#kwurry}
  spec.homepage      = "https://github.com/devpuppy/kwurry"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # kwargs (and refinements) added in 2.0
  spec.required_ruby_version = '>= 2.0.0'

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
