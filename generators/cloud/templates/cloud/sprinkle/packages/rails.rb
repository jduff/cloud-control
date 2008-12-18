package :rdoc do
  description 'Ruby Rdoc'
  version '4.1'
  apt 'rdoc'
end

package :rubygems do
  description 'Ruby Gems Package Management System'
  version '1.3.1'
  source "http://rubyforge.org/frs/download.php/45905/rubygems-#{version}.tgz" do
    custom_install 'ruby setup.rb --no-format-executable'
  end
  requires :rdoc
end
 
package :rails do
  description 'Ruby on Rails'
  gem 'rails'
  version '2.2.2'
end