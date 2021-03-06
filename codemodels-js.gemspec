# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'codemodels/js/version'

Gem::Specification.new do |spec|
  spec.platform      = 'java'
  spec.name          = "codemodels-js"
  spec.version       = CodeModels::Js::VERSION
  spec.authors       = ["Federico Tomassetti"]
  spec.email         = ["f.tomassetti@gmail.com"]
  spec.description   = %q{Building codemodels of Javascript files}
  spec.summary       = %q{Building codemodels of Javascript files. See https://github.com/ftomassetti/codemodels}
  spec.homepage      = "https://github.com/ftomassetti/codemodels-js"
  spec.license       = "APACHE2"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "codemodels"
  spec.add_dependency "rgen"      

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "simplecov"
end
