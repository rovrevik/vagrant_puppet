exec { 'apt-get update':
  path => '/usr/bin',
}

# Augeas dependencies installation and minimal use.
# http://docs.puppetlabs.com/references/latest/type.html#augeas
# http://www.augeas.net/

# What augeas packages are available?
# apt-cache search augeas
# dpkg --get-selections | grep augeas

# Go ahead and install the augeas command line tools in addition to the libraries that are needed for puppet.
# Installing the 'libaugeas-ruby', 'libaugeas-ruby1.8' packages seemed like a good idea but installed files were not
# readily accessible to the ruby version that is used to execute puppet.
$augeas_packages=['augeas-tools', 'libaugeas-dev', 'pkg-config']
package { $augeas_packages:
  ensure  => present,
  require => Exec['apt-get update'],
}

# Where do the ruby bindings for augeas get installed?
# See that stuff is installed into /usr/lib/ruby/1.8/i686-linux/_augeas.so and not in /opt/vagrant_ruby
# dpkg-query -L libaugeas-ruby1.8

# Add augeas support via gem instead for the native package manager. 
package { 'ruby-augeas':
  ensure  => present,
  provider => gem,
  require => [
    Package[libaugeas-dev], # Dependency to address 'augeas-devel not installed (RuntimeError)'
    Package[pkg-config], # Dependency to address build 'Failed to build gem native extension.''
  ]
}

# Copy hiera data source yaml files to the default directory. Actually, /var/lib/hiera is the default directory if the
# hiera.yaml exists but is empty. Apparently, these files must be put into place before a manifest that uses the hiera
# function is processed.

file { '/var/lib/hiera': ensure => directory, }
->
file { 'hiera_files':
  source        => '/vagrant/manifests/common.yaml',
  path          => '/var/lib/hiera/common.yaml',
  ensure        => present,
  recurse       => true,
  owner         => root,
  group         => root,
  mode          => 0640,
}