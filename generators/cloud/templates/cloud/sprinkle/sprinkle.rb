require 'cloud/sprinkle/packages/essential'
require 'cloud/sprinkle/packages/apache'
 
 
# Policies
#
# Names a group of packages (optionally with versions) that apply to a particular set of roles:
#
# Associates the rails policy to the application servers. Contains rails, and surrounding
# packages. Note, appserver, database, webserver and search are all virtual packages defined above.
# If there's only one implementation of a virtual package, it's selected automatically, otherwise
# the user is requested to select which one to use.
 
policy :rails, :roles => :app do
  requires :build_essential
  requires :apache
end
 
 
# Deployment
#
# Defines script wide settings such as a delivery mechanism for executing commands on the target
# system (eg. capistrano), and installer defaults (eg. build locations, etc):
#
# Configures spinkle to use capistrano for delivery of commands to the remote machines (via
# the named 'deploy' recipe). Also configures 'source' installer defaults to put package gear
# in /usr/local
 
deployment do

  # mechanism for deployment
  delivery :capistrano do
    recipes 'config/deploy'
  end
  
end
 
# End of script, given the above information, Spinkle will apply the defined policy on all roles using the
# deployment settings specified.