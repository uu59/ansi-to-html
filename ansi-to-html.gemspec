# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ansi/to/html/version'

Gem::Specification.new do |spec|
  spec.name          = "ansi-to-html"
  spec.version       = Ansi::To::Html::VERSION
  spec.authors       = ["uu59"]
  spec.email         = ["k@uu59.org"]
  spec.description   = %q{ANSI color sequence to HTML}
  spec.summary       = %q{ANSI color sequence to HTML}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
end
