package :build_essential do
  description 'Build tools'
  apt 'build-essential' do
    # Update the sources and upgrade the lists before we build essentials
    pre :install, 'apt-get update'
  end
end

package :build do
  description "Ruby header files for extensions"
  apt 'ruby1.8-dev'
  requires :build_essential
end