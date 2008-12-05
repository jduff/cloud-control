# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cloud_control}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Josh Reynolds"]
  s.date = %q{2008-12-05}
  s.default_executable = %q{cloudctl}
  s.description = %q{Controls the cloud}
  s.email = %q{jreynolds@overlay.tv}
  s.executables = ["cloudctl"]
  s.extra_rdoc_files = ["bin/cloudctl", "CHANGELOG", "lib/cloud_control.rb", "README"]
  s.files = ["bin/cloudctl", "CHANGELOG", "lib/cloud_control.rb", "Manifest", "Rakefile", "README", "cloud_control.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://www.overlay.tv}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Cloud_control", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{cloud_control}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Controls the cloud}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
