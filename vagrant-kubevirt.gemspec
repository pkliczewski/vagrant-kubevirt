$:.unshift File.expand_path("../lib", __FILE__)
require "vagrant-kubevirt/version"

Gem::Specification.new do |gem|
  # Dynamically create the authors information {name => e-mail}
  authors_hash = Hash[`git log --no-merges --reverse --format='%an,%ae'`.split("\n").uniq.collect {|i| i.split(",")}]

  gem.authors       = authors_hash.keys
  gem.email         = authors_hash.values
  gem.description   = %q{Vagrant provider for KubeVirt.}
  gem.summary       = %q{Vagrant provider for KubeVirt.}
  gem.homepage      = "https://github.com/pkliczewski/vagrant-kubevirt"
  gem.license       = "Apache-2.0"
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = `git ls-files -- spec/*`.split("\n")
  gem.name          = "vagrant-kubevirt"
  gem.require_paths = ["lib"]
  gem.version       = VagrantPlugins::KubevirtProvider::VERSION

  gem.add_runtime_dependency "fog-kubevirt", "~> 0.1.6"

  gem.add_development_dependency "rspec", "~> 3.4"
  gem.add_development_dependency "rake"
end