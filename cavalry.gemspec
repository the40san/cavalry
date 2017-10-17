# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cavalry/version"

Gem::Specification.new do |spec|
  spec.name          = "cavalry"
  spec.version       = Cavalry::VERSION
  spec.authors       = ["Masashi AKISUE"]
  spec.email         = ["m.akisue.b@gmail.com"]

  spec.summary       = %q{Simple whole data validation via ActiveRecord}
  spec.description   = %q{Simple whole data validation via ActiveRecord}
  spec.homepage      = "https://github.com/the40san/cavalry"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel", "~> 5.1"
  spec.add_dependency "activesupport", "~> 5.1"
  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
end
