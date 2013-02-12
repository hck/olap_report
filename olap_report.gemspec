# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'olap_report/version'

Gem::Specification.new do |gem|
  gem.name          = "olap_report"
  gem.version       = OlapReport::VERSION
  gem.authors       = ["Hck", "Yanzay", "Bor1s"]
  gem.description   = %q{Olap-like queries & aggregations for activerecord models using defined hierarchies & measures}
  gem.summary       = %q{Simple interface for building projection/slice queries by hierarchical table/model structure with measures calculations}
  gem.homepage      = "https://github.com/hck/olap_report"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
