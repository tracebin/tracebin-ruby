# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vizsla/version'

Gem::Specification.new do |spec|
  spec.name          = "tracebin"
  spec.version       = Vizsla::VERSION
  spec.authors       = ["Tyler Guillen"]
  spec.email         = ["tyguillen@gmail.com"]

  spec.summary       = "Easy performance analytics for your Rack/Rails app! Formerly known as 'vizsla.'"
  spec.homepage      = "https://google.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "concurrent-ruby", "~> 1.0"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'pry', '~> 0.10'
end
