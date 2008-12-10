require 'sprinkle'

class Provision < CloudControl::Base
  
  def self.options(opts)
    
    opts.on("-s", "--sprinkle-config", "Sprinkle Configuration File") do |sprinkle_config_path|
      CloudControl::Manager.options[:sprink_config_path] = sprinkle_config_path
    end
    
  end
    
  def execute
    load_state
    
    Sprinkle::Script.sprinkle File.read(CloudControl::Manager.options[:sprinkle_config_path]), CloudControl::Manager.options[:sprinkle_config_path]
    
    #save_state
  end
  
end