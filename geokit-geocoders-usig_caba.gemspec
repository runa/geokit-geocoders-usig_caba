# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "geokit-geocoders-usig_caba/version"

Gem::Specification.new do |s|
  s.name        = "geokit-geocoders-usig_caba"
  s.version     = Geokit::Geocoders::Usigcaba::VERSION
  s.authors     = ["Martin Sarsale"]
  s.email       = ["martin@sumavisos.com"]
  s.homepage    = ""
  s.summary     = %q{Geocoder using USIG-GCBA geocoder (Ciudad de Buenos Aires, Argentina)}
  s.description = %q{Geocoder using USIG-GCBA geocoder (Ciudad de Buenos Aires, Argentina)}

  s.rubyforge_project = "geokit-geocoders-usig_caba"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "geokit"
  s.add_runtime_dependency "proj4rb"
end
