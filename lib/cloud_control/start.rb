require 'ec2'
require 'ostruct'
require 'erb'


class Start < CloudControl::Base

  attr_accessor :aws_config
  attr_accessor :ec2
  
  def self.options(opts)
    
  end

  def execute
    # load_state
    load_aws_config
    start_instance
    generate_cap_config
    save_state
  end
  
  def generate_cap_config
    deployment_configuration = OpenStruct.new(deployment)
    capistrano_config = ERB.new(File.read(CloudControl::Manager.options[:capistrano_config_template_path])).result(deployment_configuration.send(:binding))
    File.open(CloudControl::Manager.options[:capistrano_config_output_path], 'w') << capistrano_config
  end
  
  def load_aws_config
    @aws_config = YAML.load_file(CloudControl::Manager.options[:aws_config_path])
    @ec2 = EC2::Base.new(:access_key_id => aws_config["access_key_id"], :secret_access_key => aws_config["secret_access_key"])
  end
  
  def start_instance
    puts 'Running instances ...'
    
    deployment[:roles] = %w(balancer app db)
    deployment[:ssh_keys] = [@aws_config["key_file"]]
    
    run_instances_for_roles(deployment[:roles])
    
    puts 'Waiting for instances to register ...'
    roles = deployment[:roles].dup
    while(roles.size > 0)
      sleep 2
      describe_response = @ec2.describe_instances
      describe_response.reservationSet.item.each do |instance|

        if deployment[:reservation_ids].include?(instance.reservationId) && instance_running?(instance)
          deployment[:reservation_ids].delete(instance.reservationId)
          role = roles.pop
          deployment[role.to_sym] = {}
          puts "#{role} instance running."
          deployment[role.to_sym][:instange_id] = instance.instancesSet.item.first.instanceId
          deployment[role.to_sym][:private_hostname] = instance.instancesSet.item.first.privateDnsName
          deployment[role.to_sym][:public_hostname] = instance.instancesSet.item.first.dnsName
        end
      end
    end
    
  end
  
  def run_instances_for_roles(roles)
    deployment[:roles].each do |role|
      run_response = @ec2.run_instances(:key_name => @aws_config["key_name"], :image_id => @aws_config["base_ami_id"], :group_id => @aws_config["ssh_security_group"])
      (deployment[:reservation_ids] ||= []) << run_response.reservationId
      puts "Instance starting for role #{role}, reservation id: " + run_response.reservationId
    end
  end
  
  def instance_running?(instance)
    instance.instancesSet.item.first.instanceState.name == "running"
  end
  
end
