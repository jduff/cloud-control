# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cloud_control}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Josh Reynolds"]
  s.date = %q{2009-01-22}
  s.default_executable = %q{cloudctl}
  s.description = %q{Controls the Cloud}
  s.email = %q{jreynolds@overlay.tv}
  s.executables = ["cloudctl"]
  s.extra_rdoc_files = ["bin/cloudctl", "CHANGELOG", "lib/cloud_control/base.rb", "lib/cloud_control/bundle.rb", "lib/cloud_control/deploy.rb", "lib/cloud_control/init.rb", "lib/cloud_control/provision.rb", "lib/cloud_control/start.rb", "lib/cloud_control.rb", "README", "TODO"]
  s.files = ["bin/cloudctl", "CHANGELOG", "generators/cloud/cloud_generator.rb", "generators/cloud/templates/cloud/apache.conf.erb", "generators/cloud/templates/cloud/aws.yml", "generators/cloud/templates/cloud/deploy.rb", "generators/cloud/templates/cloud/deployment.yml", "generators/cloud/templates/cloud/haproxy.cfg.erb", "generators/cloud/templates/cloud/sprinkle/packages/apache.rb", "generators/cloud/templates/cloud/sprinkle/packages/essential.rb", "generators/cloud/templates/cloud/sprinkle/packages/haproxy.rb", "generators/cloud/templates/cloud/sprinkle/packages/mysql.rb", "generators/cloud/templates/cloud/sprinkle/packages/passenger.rb", "generators/cloud/templates/cloud/sprinkle/packages/rails.rb", "generators/cloud/templates/cloud/sprinkle/sprinkle.rb", "generators/cloud/templates/config/deploy.rb", "lib/cloud_control/base.rb", "lib/cloud_control/bundle.rb", "lib/cloud_control/deploy.rb", "lib/cloud_control/init.rb", "lib/cloud_control/provision.rb", "lib/cloud_control/start.rb", "lib/cloud_control.rb", "Manifest", "Rakefile", "README", "templates/stage.rb.erb", "test/test_cloud_control.rb", "test/test_helper.rb", "TODO", "cloud_control.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://www.overlay.tv}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Cloud_control", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{cloud_control}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Controls the Cloud}
  s.test_files = ["test/test_cloud_control.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<capistrano>, [">= 0", "= 2.5.0"])
      s.add_runtime_dependency(%q<amazon-ec2>, [">= 0", "= 0.2.15"])
      s.add_runtime_dependency(%q<sprinkle>, [">= 0", "= 0.2.0"])
    else
      s.add_dependency(%q<capistrano>, [">= 0", "= 2.5.0"])
      s.add_dependency(%q<amazon-ec2>, [">= 0", "= 0.2.15"])
      s.add_dependency(%q<sprinkle>, [">= 0", "= 0.2.0"])
    end
  else
    s.add_dependency(%q<capistrano>, [">= 0", "= 2.5.0"])
    s.add_dependency(%q<amazon-ec2>, [">= 0", "= 0.2.15"])
    s.add_dependency(%q<sprinkle>, [">= 0", "= 0.2.0"])
  end
end
