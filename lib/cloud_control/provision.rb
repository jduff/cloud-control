require 'sprinkle'

class Provision < CloudControl::Base
  
  def self.options(opts)
    
    opts.on("-s", "--sprinkle-config", "Sprinkle Configuration File") do |sprinkle_config_path|
      CloudControl::Manager.options[:sprink_config_path] = sprinkle_config_path
    end
    
  end
    
  def execute
    load_state
    
    powder = Sprinkle::Script.new
    powder.instance_eval(File.read(CloudControl::Manager.options[:sprinkle_config_path]), CloudControl::Manager.options[:sprinkle_config_path])
    powder.deployment do    
      # mechanism for deployment
      delivery :capistrano do
        config.set :run_method, :run
        config.ssh_options[:keys] = CloudControl::Manager.deployment[:ssh_keys].join(' ')
        CloudControl::Manager.deployment[:roles].each do |role|
          config.role(role.to_sym, CloudControl::Manager.deployment[role.to_sym][:public_hostname])
        end
        
      end
      
      # source based package installer defaults
      source do
        prefix   '/usr/local'           # where all source packages will be configured to install
        archives '/usr/local/sources'   # where all source packages will be downloaded to
        builds   '/usr/local/build'     # where all source packages will be built
      end
      
    end
    
    powder.sprinkle
    
  
  end
  
end