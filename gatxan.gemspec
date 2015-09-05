# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gatxan/version'

Gem::Specification.new do |spec|
  spec.name          = "gatxan"
  spec.version       = Gatxan::VERSION
  spec.authors       = ["Pere Urbon-Bayes"]
  spec.email         = ["pere.urbon@gmail.com"]

  spec.summary       = %q{Jenkins and Github management tool}
  spec.description   = %q{Useful to manage and check infrastructure shared with jenkins and github repos}
  spec.homepage      = "http://www.purbon.com"
  spec.license       = "Apache License (2.0)"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
