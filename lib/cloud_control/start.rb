require 'ec2'

class Start < CloudControl::Base

  attr_accessor :aws_config
  attr_accessor :ec2
  
  def self.options(opts)
    
    opts.on("-c", "Provisioner options") do
      CloudControl::Manager.options[:c] = true
      puts "Setting options from provisioner"
    end
    
  end

  def execute
    load_state
    load_aws_config
    start_instance
    save_state
  end
  
  def load_aws_config
    @aws_config = YAML.load_file(CloudControl::Manager.options[:aws_config_path])
    @ec2 = EC2::Base.new(:access_key_id => aws_config["access_key_id"], :secret_access_key => aws_config["secret_access_key"])
  end
  
  def start_instance
    puts 'Running instance ...'
    run_response = @ec2.run_instances(:key_name => @aws_config["key_name"], :image_id => @aws_config["base_ami_id"], :group_id => @aws_config["ssh_security_group"])
    deployment[:reservation_id] = run_response.reservationId
    puts 'Instance starting, reservation id: ' + deployment[:reservation_id]
    
    
    puts 'Waiting for instance to register ...'
    while(deployment[:private_hostname].nil? && deployment[:public_hostname].nil?)
      sleep 2
      describe_response = @ec2.describe_instances
      describe_response.reservationSet.item.each do |instance|

        if instance.reservationId == deployment[:reservation_id]
          deployment[:private_hostname] = instance.instancesSet.item.first.instanceId
          deployment[:private_hostname] = instance.instancesSet.item.first.privateDnsName
          deployment[:public_hostname] = instance.instancesSet.item.first.dnsName
          break
        end
      end
    end
    puts 'Instance started, instance id: ' + deployment[:private_hostname]
    
  end
  
end