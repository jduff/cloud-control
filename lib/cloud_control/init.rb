require 'rubigen'
require 'rubigen/scripts/generate'
    
class Init < CloudControl::Base
  
  def self.options(opt)
  end
  
  def execute

    args = ['.']
    RubiGen::Base.prepend_sources(RubiGen::PathSource.new(:app, File.join(File.dirname(__FILE__), "..", "..", "generators")))
    RubiGen::Scripts::Generate.new.run(args, :generator => 'cloud')
    
  end
  
end