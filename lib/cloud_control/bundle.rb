class Bundle < CloudControl::Base
  
  
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
    
    aws_config = YAML.load_file(CloudControl::Manager.options[:aws_config_path])
    capistrano.set :aws_config, aws_config
    
    capistrano.role(:app, CloudControl::Manager.deployment[:app][:public_hostname])
    
    # capistrano.find_and_execute_task("ec2:bundle", :before => :start, :after => :finish)
    
    ec2 = EC2::Base.new(:access_key_id => aws_config["access_key_id"], :secret_access_key => aws_config["secret_access_key"])
    ec2.register_image(:image_location => "#{aws_config["ami_s3_bucket"]}/app_deployment_#{capistrano.deployment_time}.manifest.xml")
    
    
    capistrano.set :deployment_time, "2009-01-14-1618"

    image = nil
    while(image == nil)
      ec2.describe_images(:owner_id => aws_config["account_id"].to_s).imagesSet.item.each do |item|
        if item.imageLocation == "#{aws_config["ami_s3_bucket"]}/app_deployment_#{capistrano.deployment_time}.manifest.xml"
          image = item
          break
        end
      end
      sleep 2
    end
    

    run_response = ec2.run_instances(:key_name => aws_config["key_name"], :image_id => image.imageId, :group_id => ["default", aws_config["ssh_security_group"], aws_config["http_security_group"]])
    puts "Running instance, #{run_response.reservationId}"    

    running = false
    instance = nil
    while(!running)
      sleep 2
      describe_response = ec2.describe_instances
      describe_response.reservationSet.item.each do |instance|
        if instance.reservationId == run_response.reservationId && instance.instancesSet.item.first.instanceState.name == "running"
          running = true
        end
      end
    end
   
   puts "Instance up" 
   
   #update haproxy
   
   capistrano.role(:balancer, CloudControl::Manager.deployment[:balancer][:public_hostname])
   pp image
   capistrano.role(:app, instance.instancesSet.item.first.dnsName)
      
   capistrano.find_and_execute_task("deploy:balancer:generate_config", :before => :start, :after => :finish) 
      
   save_state   
  end
  
  
end