require 'capistrano'

class Deploy < CloudControl::Base

  def self.options(opts)
        
  end
    
  def execute
    load_state
    load_aws_config

    capistrano = Capistrano::Configuration.new
    capistrano.load 'standard'
    capistrano.load 'Capfile'
    capistrano.load 'cloud/deploy'

    capistrano.logger.level = 10
    
    capistrano.set :run_method, :run
    capistrano.set :user, 'root'
    capistrano.set :stage, CloudControl::Manager.options[:stage]
    capistrano.set :rails_env, CloudControl::Manager.options[:environment]
    capistrano.set :gateway, CloudControl::Manager.deployment["balancer"]["public_hostname"]
        
    capistrano.ssh_options[:keys] = CloudControl::Manager.aws_config["key_file"]
       
    CloudControl::Manager.deployment.keys.each do |role|
      if role == "db"
        capistrano.role(role.to_sym, CloudControl::Manager.deployment[role]["private_hostname"], :primary => true)
      else
        capistrano.role(role.to_sym, CloudControl::Manager.deployment[role]["private_hostname"])
      end
    end

    capistrano.find_and_execute_task("deploy:setup", :before => :start, :after => :finish)
    capistrano.find_and_execute_task("deploy", :before => :start, :after => :finish)

  end
  
end