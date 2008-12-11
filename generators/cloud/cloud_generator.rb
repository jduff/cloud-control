require 'rbconfig'

class CloudGenerator < RubiGen::Base
  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])
                              
  default_options   :shebang => DEFAULT_SHEBANG
  
  attr_reader :app_name, :module_name
  
  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @destination_root = args.shift
    @app_name     = File.basename(File.expand_path(@destination_root))
    @module_name  = app_name.camelize
    extract_options
  end
    
  def manifest
    # Use /usr/bin/env if no special shebang was specified
    script_options     = { :chmod => 0755, :shebang => options[:shebang] == DEFAULT_SHEBANG ? nil : options[:shebang] }
    windows            = (RUBY_PLATFORM =~ /dos|win32|cygwin/i) || (RUBY_PLATFORM =~ /(:?mswin|mingw)/)
    
    record do |m|
      # Root directory and all subdirectories.
      m.directory 'cloud/sprinkle/packages'
      
      # Root
      # m.template_copy_each %w( Rakefile )
      m.file_copy_each     %w( 
                                aws.yml
                                deploy.rb.erb
                                sprinkle/sprinkle.rb
                                sprinkle/packages/apache.rb
                                sprinkle/packages/essential.rb
                             ), 'cloud'

      # Test helper
      # m.template   "test_helper.rb",        "test/test_helper.rb"

      # Scripts
      # %w( generate ).each do |file|
      #   m.template "script/#{file}",        "script/#{file}", script_options
      #   m.template "script/win_script.cmd", "script/#{file}.cmd", 
      #     :assigns => { :filename => file } if windows
      # end
   
    end
  end

  protected
    def banner
      <<-EOS
Create a stub for #{File.basename $0} to get started.

Usage: #{File.basename $0} /path/to/your/app [options]"
EOS
    end
    
    def extract_options
    end

    def add_options!(opts)
      opts.separator ''
      opts.separator "#{File.basename $0} options:"
      opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end
    
end
