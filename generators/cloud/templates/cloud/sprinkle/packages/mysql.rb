package :mysql, :provides => :database do
  description 'MySQL Database'
  apt %w( mysql-server mysql-client ) do
    post :install, 'sed -i "s|^bind-address.*$|#bind-address 127\.0\.0\.1|" /etc/mysql/my.cnf'
    post :install, '/etc/init.d/mysql restart'
  end
  requires :mysql_dev
end

package :mysql_dev do
  apt 'libmysqlclient15-dev'
end
 
package :mysql_ruby_driver do
  description 'Ruby MySQL database driver'
  gem 'mysql'
  requires :mysql_dev
end