require 'optparse'
require 'rubygems'
require 'pp'
require File.dirname(__FILE__) + '/../lib/cloud_control/base'
require File.dirname(__FILE__) + '/../lib/cloud_control/init'
require File.dirname(__FILE__) + '/../lib/cloud_control/start'
require File.dirname(__FILE__) + '/../lib/cloud_control/provision'

module CloudControl
  class Manager
    AVAILABLE_ACTIONS = %w{ init start provision deploy snapshot }
  
    class << self
      attr_accessor :options
    end

    def self.execute
      args = ARGV.reverse
      @options = {
        :environment => "staging",
        # :action => "deploy",
        :aws_config_path => "cloud/aws.yml",
        :sprinkle_config_path => "cloud/sprinkle/sprinkle.rb",
        :capistrano_config_template_path => "cloud/deploy.rb.erb",
        :capistrano_config_output_dir => "config/deploy",
        :deployment_config_path => "cloud/deployment.yml"
      }
      
      @options[:action] = ARGV.pop
      @options[:environment] = ARGV.pop
   
      if !AVAILABLE_ACTIONS.include?(@options[:action])
        puts "Sorry, \"#{@options[:action]}\" is not a valid action to preform."
        exit(1)
      end

      # The following is for automatic chaining of actions, maybe useful in the future
      # performing_actions = AVAILABLE_ACTIONS[0, AVAILABLE_ACTIONS.index(@options[:action]) + 1]
      # actions = CloudControl::Base.get_actions(performing_actions)

      actions = CloudControl::Base.get_actions([@options[:action]])

      opts = OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename($0)} [options] environment action"

        actions.each do |action|
          action.class.options(opts) # Build options from action class
        end
      
        opts.on("-a", "--aws-config FILE", "Path to Amazon AWS YAML File") { |aws_config_path|
          CloudControl::Manager.options[:aws_config_path] = aws_config_path
        }
      
        opts.on("-V", "--version", "Cloud Control version") do
          puts "CloudControl Version 0.0.1"
          exit
        end
      
      end

      opts.parse!
      
      actions.each do |action|
        action.execute
      end
      
    end

  end
end