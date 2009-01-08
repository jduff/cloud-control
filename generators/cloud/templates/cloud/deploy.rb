task :ls, :roles => :app do
  run "cd /; ls"
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
  
  namespace :apache do
    task :copy_virtual_host, :roles => :app, :except => { :no_release => true } do
      run "cp #{current_path}/config/apache/#{stage} /etc/apache2/sites-available/"
      run "a2ensite #{stage}"
      deploy.apache.restart
    end
    
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "/etc/init.d/apache2 restart"
    end
  end
  
  namespace :database do
    task :update_host, :except => { :no_release => true } do
      db_config = YAML.load_file("config/database.yml.template")
      db_config[stage]["host"] = roles[:db_private].servers.first.to_s
      
      put db_config.to_yaml, "#{current_path}/config/database.yml"
    end
  end
  
  on :after, :only => "deploy" do
   deploy.apache.copy_virtual_host
   deploy.set_owner
  end
  
  on :after, :only => "deploy:symlink" do
    deploy.database.update_host
  end
  
end