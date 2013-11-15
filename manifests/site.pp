# Where are the puppet logs on the guest?
# /var/lib/puppet/reports/ and /var/lib/puppet/state/state.yaml

# What ruby version is vagrant executing on the guest?
# Vagrant doesn't execute ruby directly. It executes puppet via ssh which uses ruby.
# for the "official" vagrant boxes: cat /home/vagrant/postinstall.sh | grep ruby_home
# for Puppet Labs boxes: cat /home/vagrant/ruby.sh | grep RUBY_VERSION=
# cat /opt/ruby/bin/puppet | grep '#!'

# What puppet version is executing on the guest?
# The Puppet Labs and Vagrant boxes install puppet with gem. Interesting, given that puppet says that installing from
# gems is "Not Recommended". I wonder why? What is the trade off? Is it just more complicated for the user? The vagrant
# box has it backed in. (currently 2.7.19 ruby-gem)
# The Puppet Labs boxes simply install the latest puppet vi gem. (currently 3.1.1)
# executed: gem list | grep puppet
# or: sudo find / -name  puppet

# Where are the puppet logs on the guest?
# /var/lib/puppet/reports/ and /var/lib/puppet/state/state.yaml

# How does vagrant start puppet apply on the guest?
# Vagrant typically executes shell commands over ssh. Debugging reveals that puppet apply is executed as follows.
# sudo -H bash -l
# puppet apply --color=false --manifestdir /tmp/vagrant-puppet/manifests --detailed-exitcodes /tmp/vagrant-puppet/manifests/default.pp || [ $? -eq 2 ]

exec { "apt-get update":
  path => "/usr/bin",
}

# Augeas dependencies installation and minimal use.
# http://docs.puppetlabs.com/references/latest/type.html#augeas
# http://www.augeas.net/

# What augeas packages are available?
# apt-cache search augeas
# dpkg --get-selections | grep augeas

# Go ahead and install the augeas command line tools in addition to the libraries that are needed for puppet.
# installing the "libaugeas-ruby", "libaugeas-ruby1.8" packages seemed like a good idea but installed files were not
# readily accessible to the ruby version that is used to execute puppet.
$augeas_packages=["augeas-tools", "libaugeas-dev", "pkg-config"]
package { $augeas_packages:
  ensure  => present,
  require => Exec["apt-get update"],
}

# Where do the ruby bindings for augeas get installed?
# See that stuff is installed into /usr/lib/ruby/1.8/i686-linux/_augeas.so and not in /opt/vagrant_ruby
# dpkg-query -L libaugeas-ruby1.8

# Add augeas support via gem instead for the native package manager. 
package { 'ruby-augeas':
  ensure  => present,
  provider => 'gem',
  require => [
    Package["libaugeas-dev"], # Dependency to address "augeas-devel not installed (RuntimeError)
    Package["pkg-config"], # Dependency to address build "Failed to build gem native extension."
  ]
}

# Just add a comment to any old shellvars file. Fails with Error: Could not find a suitable provider for augeas.
# This does not work because the bindings are not visible to the ruby used to execute puppet on the guest.
augeas { "bootlogd_11_15_2013":
  context => "/files/etc/default/bootlogd",
  onlyif => "match #comment[. = 'change 11_15_2013'] size == 0",
  changes => [
      "set /files/etc/default/bootlogd/#comment[last()+1] 'change 11_15_2013'",
  ],
  require => [
    Package["ruby-augeas"],
  ]
}