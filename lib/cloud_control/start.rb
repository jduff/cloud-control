require 'ec2'
require 'ostruct'
require 'erb'


class Start < CloudControl::Base

  attr_accessor :aws_config
  attr_accessor :ec2
  
  def self.options(opts)
    opts.on("-d", "--deployment-config", "Deployment Configuration File") do |deployment_config_path|
      CloudControl::Manager.options[:deployment_config_path] = deployment_config_path
    end
  end

  def execute
    load_state
    load_aws_config
    load_deployment_config
    start_instances
    generate_cap_config
    save_state
  end
  
  def load_deployment_config
    deployment_config = YAML.load_file(CloudControl::Manager.options[:deployment_config_path])
    CloudControl::Manager.deployment[:roles] = deployment_config.keys
  end
  
  def generate_cap_config
    deployment_configuration = OpenStruct.new(CloudControl::Manager.deployment)
    template_file = File.join(File.dirname(__FILE__), '..', '..', 'templates', 'stage.rb.erb')
    output_file = File.join(CloudControl::Manager.options[:capistrano_config_output_dir], CloudControl::Manager.options[:stage] + '.rb')
    capistrano_config = ERB.new(File.read(template_file)).result(deployment_configuration.send(:binding))
    File.open(output_file, 'w') << capistrano_config
  end
  
  def load_aws_config
    @aws_config = YAML.load_file(CloudControl::Manager.options[:aws_config_path])
    @ec2 = EC2::Base.new(:access_key_id => aws_config["access_key_id"], :secret_access_key => aws_config["secret_access_key"])
  end
  
  def start_instances
    puts 'Running instances ...'
    
    CloudControl::Manager.deployment[:ssh_keys] = [@aws_config["key_file"]]
    
    run_instances_for_roles(CloudControl::Manager.deployment[:roles])
    
    puts 'Waiting for instances to register ...'
    roles = CloudControl::Manager.deployment[:roles].dup
    while(roles.size > 0)
      sleep 2
      describe_response = @ec2.describe_instances
      describe_response.reservationSet.item.each do |instance|

        if CloudControl::Manager.deployment[:reservation_ids].include?(instance.reservationId) && instance_running?(instance)
          CloudControl::Manager.deployment[:reservation_ids].delete(instance.reservationId)
          role = roles.pop
          CloudControl::Manager.deployment[role.to_sym] = {}
          puts "#{role} instance running."
          CloudControl::Manager.deployment[role.to_sym][:instange_id] = instance.instancesSet.item.first.instanceId
          CloudControl::Manager.deployment[role.to_sym][:private_hostname] = instance.instancesSet.item.first.privateDnsName
          CloudControl::Manager.deployment[role.to_sym][:public_hostname] = instance.instancesSet.item.first.dnsName
        end
      end
    end
    
  end
  
  def run_instances_for_roles(roles)
    CloudControl::Manager.deployment[:roles].each do |role|
      run_response = @ec2.run_instances(:key_name => @aws_config["key_name"], :image_id => @aws_config["base_ami_id"], :group_id => @aws_config["ssh_security_group"])
      (CloudControl::Manager.deployment[:reservation_ids] ||= []) << run_response.reservationId
      puts "Instance starting for role #{role}, reservation id: " + run_response.reservationId
    end
  end
  
  def instance_running?(instance)
    instance.instancesSet.item.first.instanceState.name == "running"
  end
  
end
