package :rubygems do
  description 'Ruby Gems Package Management System'
  version '1.2.0'
  source "http://rubyforge.org/frs/download.php/38646/rubygems-#{version}.tgz" do
    custom_install 'ruby setup.rb'
  end
end
 
package :rails do
  description 'Ruby on Rails'
  gem 'rails'
  version '2.1.0'
end