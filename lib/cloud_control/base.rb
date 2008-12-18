module CloudControl
  class Base
    
    attr_accessor :deployment
    
    def initialize
      @deployment = {}
    end

    def save_state
      File.open('cloud/cloud_control.state', 'w') do |state|
        YAML.dump(CloudControl::Manager.deployment, state)
      end
    end
    
    def load_state
      CloudControl::Manager.deployment = YAML.load_file('cloud/cloud_control.state') if File.exists?('cloud/cloud_control.state')
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