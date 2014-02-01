# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bitlbee_config/version'

Gem::Specification.new do |spec|
  spec.name          = "bitlbee_config"
  spec.version       = BitlbeeConfig::VERSION
  spec.authors       = ["Nils Landt"]
  spec.email         = ["nils@promisedlandt.de"]
  spec.description   = %q{Create, read and modify configuration files for bitlbee}
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/promisedlandt/bitlbee_config"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", "~> 1.6"
  spec.add_dependency "mixlib-shellout", "~> 1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.1"
  spec.add_development_dependency "debugger", "~> 1.6"
  spec.add_development_dependency "rubocop", "~> 0.1"
  spec.add_development_dependency "minitest", "~> 5"
  spec.add_development_dependency "guard", "~> 2"
  spec.add_development_dependency "guard-minitest", "~> 2"
  spec.add_development_dependency "yard", "~> 0.8"
  spec.add_development_dependency "mocha", "~> 1"
end
