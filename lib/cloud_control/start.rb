require 'EC2'
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
    load_state(true)
    load_aws_config    
    @ec2 = EC2::Base.new(:access_key_id => CloudControl::Manager.aws_config["access_key_id"], :secret_access_key => CloudControl::Manager.aws_config["secret_access_key"])
    
    start_instances
    check_running_instances
    generate_cap_config
    save_state
  end
    
  def generate_cap_config
    deployment_configuration = OpenStruct.new(CloudControl::Manager.deployment)
    deployment_configuration.roles = CloudControl::Manager.deployment.keys
    deployment_configuration.ssh_keys = CloudControl::Manager.aws_config["key_file"]
    template_file = File.join(File.dirname(__FILE__), '..', '..', 'templates', 'stage.rb.erb')
    output_file = File.join(CloudControl::Manager.options[:capistrano_config_output_dir], CloudControl::Manager.options[:stage] + '.rb')
    capistrano_config = ERB.new(File.read(template_file)).result(deployment_configuration.send(:binding))
    File.open(output_file, 'w') << capistrano_config
  end
  
  def start_instances
    puts 'Running instances ...'
    
    reservation_ids, starting_roles = run_instances_for_roles(CloudControl::Manager.deployment.keys)
    
    puts 'Waiting for instances to register ...'
    while(starting_roles.size > 0)
      sleep 2
      
      describe_response = @ec2.describe_instances
      describe_response.reservationSet.item.each do |instance|

        if(reservation_ids.include?(instance.reservationId) && instance_running?(instance))
          reservation_ids.delete(instance.reservationId)
          role = starting_roles.pop
          puts "#{role} instance running."
          CloudControl::Manager.deployment[role]["instance_id"] = instance.instancesSet.item.first.instanceId
          CloudControl::Manager.deployment[role]["private_hostname"] = instance.instancesSet.item.first.privateDnsName
          CloudControl::Manager.deployment[role]["public_hostname"] = instance.instancesSet.item.first.dnsName
        end
      end
    end
    
  end

  def check_running_instances
    instance_ids = CloudControl::Manager.deployment.collect { |role| role[1]["instance"]  }.compact
    instance_ids_to_role = {}
    CloudControl::Manager.deployment.collect { |role| instance_ids_to_role[role[1]["instance"]] = role[0] if role[1]["instance"] != nil }

    describe_response = @ec2.describe_instances(:instance_id => instance_ids)
    
    describe_response.reservationSet.item.each do |instance|
      role = instance_ids_to_role[instance.instancesSet.item.first.instanceId]
      CloudControl::Manager.deployment[role]["private_hostname"] = instance.instancesSet.item.first.privateDnsName
      CloudControl::Manager.deployment[role]["public_hostname"] = instance.instancesSet.item.first.dnsName
    end
    
  end
  
  def run_instances_for_roles(roles)
    reservation_ids = []
    starting_roles = []
    CloudControl::Manager.deployment.keys.each do |role|
      if CloudControl::Manager.deployment[role]["instance"] == nil
        run_response = @ec2.run_instances(
            :key_name => CloudControl::Manager.aws_config["key_name"],
            :image_id => CloudControl::Manager.deployment[role]["ami"] || CloudControl::Manager.aws_config["base_ami_id"],
            :instance_type => CloudControl::Manager.deployment[role]["instance_type"] || "m1.small",
            :group_id => CloudControl::Manager.deployment[role]["security_groups"]
          )
        starting_roles << role
        reservation_ids << run_response.reservationId
        puts "Instance starting for role #{role}, reservation id: " + run_response.reservationId
      end
    end
    [reservation_ids, starting_roles]
  end
  
  def instance_running?(instance)
    instance.instancesSet.item.first.instanceState.name == "running"
  end
  
end
