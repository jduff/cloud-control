require 'capistrano'

class Deploy < CloudControl::Base

  def self.options(opts)
        
  end
    
  def execute
    load_state

    capistrano = Capistrano::Configuration.new
    capistrano.load 'standard'
    capistrano.load 'Capfile'
    capistrano.load 'cloud/deploy'

    capistrano.logger.level = 10
    
    capistrano.set :run_method, :run
    capistrano.set :stage, CloudControl::Manager.options[:stage]
    capistrano.ssh_options[:keys] = CloudControl::Manager.deployment[:ssh_keys].join(' ')
    
    CloudControl::Manager.deployment[:roles].each do |role|
      capistrano.role(role.to_sym, CloudControl::Manager.deployment[role.to_sym][:public_hostname])
      capistrano.role((role + "_private").to_sym, CloudControl::Manager.deployment[role.to_sym][:private_hostname], :no_release => true)
    end

    capistrano.find_and_execute_task("deploy:setup", :before => :start, :after => :finish)
    capistrano.find_and_execute_task("deploy", :before => :start, :after => :finish)

  end
  
end