require 'optparse'
require 'rubygems'
require 'pp'

require File.dirname(__FILE__) + '/../lib/cloud_control/base'
require File.dirname(__FILE__) + '/../lib/cloud_control/init'
require File.dirname(__FILE__) + '/../lib/cloud_control/start'
require File.dirname(__FILE__) + '/../lib/cloud_control/provision'
require File.dirname(__FILE__) + '/../lib/cloud_control/deploy'
require File.dirname(__FILE__) + '/../lib/cloud_control/bundle'

module CloudControl
  class Manager
    AVAILABLE_ACTIONS = %w{ init start provision deploy bundle }
  
    class << self
      attr_accessor :options
      attr_accessor :deployment
      attr_accessor :aws_config
    end

    def self.execute
      args = ARGV.reverse
      @deployment = {}
      @aws_config = {}
      @options = {
        :stage => "staging",
        :environment => "staging",
        # :action => "deploy",
        :aws_config_path => "cloud/aws.yml",
        :sprinkle_config_path => "cloud/sprinkle/sprinkle.rb",
        :capistrano_config_template_path => "cloud/deploy.rb.erb",
        :capistrano_config_output_dir => "config/deploy",
        :deployment_config_path => "cloud/deployment.yml"
      }
      
      @options[:action] = ARGV.pop
      # @options[:stage] = ARGV.pop
   
      if !AVAILABLE_ACTIONS.include?(@options[:action])
        puts "Sorry, \"#{@options[:action]}\" is not a valid action to preform."
        exit(1)
      end

      # The following is for automatic chaining of actions, maybe useful in the future
      # performing_actions = AVAILABLE_ACTIONS[0, AVAILABLE_ACTIONS.index(@options[:action]) + 1]
      # actions = CloudControl::Base.get_actions(performing_actions)

      actions = CloudControl::Base.get_actions([@options[:action]])

      opts = OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename($0)} [options] stage action"

        actions.each do |action|
          action.class.options(opts) # Build options from action class
        end
      
        opts.on("-a", "--aws-config FILE", "Path to Amazon AWS YAML File") { |aws_config_path|
          CloudControl::Manager.options[:aws_config_path] = aws_config_path
        }
        
        opts.on("-e", "--environment ENVIRONMENT", "The Rails Environment that app will run in, default staging") { |environment|
          CloudControl::Manager.options[:environment] = environment
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

module Sprinkle
  module Deployment
    class Deployment
      def delivery(type, &block)
        @style = ("Sprinkle::Actors::" + type.to_s.titleize).constantize.new &block
      end
    end
  end
end

