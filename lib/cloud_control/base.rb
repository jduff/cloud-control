module CloudControl
  class Base
    
    def save_state
      File.open('cloud/cloud_control.state', 'w') do |state|
        YAML.dump(CloudControl::Manager.deployment, state)
      end
    end
    
    def load_aws_config
      CloudControl::Manager.aws_config = YAML.load_file(CloudControl::Manager.options[:aws_config_path])
    end
    
    def load_state(only_deployment=false)
      if File.exists?('cloud/cloud_control.state') && !only_deployment
        CloudControl::Manager.deployment = YAML.load_file('cloud/cloud_control.state') 
      else 
        CloudControl::Manager.deployment = YAML.load_file(CloudControl::Manager.options[:deployment_config_path])
      end
    end
    
    def self.get_actions(actions)
      action_objs = []
      actions.each do |action|
        action_objs << Kernel.const_get(action.capitalize).new
      end
      action_objs
    end
  end
end