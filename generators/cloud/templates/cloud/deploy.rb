require 'erb'

# set :repository, ""
# set :real_revision, source.local.query_revision(revision) { |cmd| 
#   with_env("LC_ALL", "C") { `svn info -rHEAD` }
# }

if !get(:database_password, nil)
  set(:database_password) do
    Capistrano::CLI.ui.ask "Database Password: "
  end
end

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
 
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
    
  task :set_owner, :except => { :no_release => true }  do
    run "chown -R www-data:www-data #{current_path}/../.."
  end
  
  task :start_svn_ssh_tunnel, :roles => :balancer do
    connection_factory.instance_variable_get(:@gateway).instance_variable_get(:@session).forward.remote(3690, svn_host, 3690, '0.0.0.0')
    set :repository, "svn://#{roles[:balancer].servers.first.to_s}#{svn_path}"
  end

  namespace :apache do
    task :generate_config, :roles => :app, :except => { :no_release => true } do
      template = File.read('cloud/apache.conf.erb')
      result = ERB.new(template).result(binding)
      
      run 'mkdir -p /etc/apache2/sites-available'
      put result, "/etc/apache2/sites-available/#{stage}"
      
      run "a2ensite #{stage}"
      deploy.apache.restart
    end
    
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "/etc/init.d/apache2 restart"
    end
  end
  
  namespace :database do
    task :update_config, :except => { :no_release => true } do
      db_config = YAML.load_file("config/database.yml.template")
      db_config[stage]["host"] = roles[:db].servers.first.to_s
      db_config[stage]["password"] = database_password
      
      put db_config.to_yaml, "#{current_path}/config/database.yml"
    end
    
    task :create, :roles => :db do
      db_config = YAML.load_file("config/database.yml.template")
                        
      run "mysql -u root -e 'create database if not exists `#{db_config[stage]["database"]}`;'"
      run "mysql -u root -e \"grant all on \\`#{db_config[stage]["database"]}\\`.* to '#{db_config[stage]["username"]}'@'%' identified by 'password';\""
      run "mysql -u root -e \"grant reload on *.* to '#{db_config[stage]["username"]}'@'%' identified by '#{db_config[stage]["password"]}';\""
      run "mysql -u root -e \"grant super on *.* to '#{db_config[stage]["username"]}'@'%' identified by '#{db_config[stage]["password"]}';\""
      run "mysql -u root -e \"grant all on \\`#{db_config[stage]["database"]}\\`.* to '#{db_config[stage]["username"]}'@'localhost' identified by '#{db_config[stage]["password"]}';\""
      run "mysql -u root -e \"grant reload on *.* to '#{db_config[stage]["username"]}'@'localhost' identified by '#{db_config[stage]["password"]}';\""
      run "mysql -u root -e \"grant super on *.* to '#{db_config[stage]["username"]}'@'localhost' identified by '#{db_config[stage]["password"]}';\""
    end
        
  end
  
  namespace :balancer do
    task :generate_config, :roles => :balancer do
      template = File.read('cloud/haproxy.cfg.erb')
      result = ERB.new(template).result(roles[:app].send(:binding))
      put result, "/etc/haproxy.cfg"
      deploy.balancer.start
    end
    
    task :start, :roles => :balancer do
      run "haproxy -p /var/run/haproxy.pid -D -f /etc/haproxy.cfg -p /var/run/haproxy.pid"
    end
    
    task :stop, :roles => :balancer do
      run "kill -9 `cat /var/run/haproxy.pid`"
    end
    
    task :reload, :roles => :balancer do
      run "haproxy -f /etc/haproxy.cfg -p /var/run/haproxy.pid -D -st `cat /var/run/haproxy.pid`"
    end
  end
  
  on :before, :only => "deploy" do
    # deploy.start_svn_ssh_tunnel
  end
  
  on :after, :only => "deploy" do
   deploy.apache.generate_config
   deploy.set_owner
   deploy.balancer.generate_config
  end
  
  on :after, :only => "deploy:symlink" do
    deploy.database.update_config
  end
  
end

namespace :ec2 do
  task :bundle, :roles => :app, :except => { :no_release => true } do
    raise "Can only be run when there is one app server" if roles[:app].servers.size > 1
    
    ec2.upload_keys
    
    set :deployment_time, Time.now.strftime('%Y-%m-%d-%H%M')
    run "ec2-bundle-vol -k /mnt/private_key -u #{aws_config["account_id"]} -c /mnt/cert -r i386 -p app_deployment_#{deployment_time}" # The ARCH should be configurable
    
    ec2.upload_bundle
  end
  
  task :upload_keys, :roles => :app, :except => { :no_release => true } do
    upload aws_config["cert_file"], "/mnt/cert"
    upload aws_config["key_file"], "/mnt/private_key"
  end
  
  task :upload_bundle, :roles => :app, :except => { :no_release => true } do
    run "ec2-upload-bundle -b #{aws_config["ami_s3_bucket"]} -m /tmp/app_deployment_#{deployment_time}.manifest.xml -a #{aws_config["access_key_id"]} -s #{aws_config["secret_access_key"]}"
  end  
  
end