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

# Just add a comment to any old file. Fails with Error: Could not find a suitable provider for augeas.
# This did not work initially because the bindings were not visible to the ruby used to execute puppet on the guest.
# This works now because the bindings installed with the ruby-augeas gem are visible in successive manifests executed after the gem is installed.
augeas { "hosts_11_15_2013":
  context => "/files/etc/hosts",
  onlyif => "match #comment[. = 'change hosts_11_15_2013'] size == 0",
  changes => [
      "set /files/etc/hosts/#comment[last()+1] 'change hosts_11_15_2013'",
  ],
  # require => Package["ruby-augeas"],
  # Requirements for augueas are satisfied in the augeas_requirements.pp manifest
}

package { "openjdk-6-jdk":
  ensure  => present,
  require => Exec["apt-get update"],
}

# What packages have tomcat and admin: apt-cache search tomcat admin
# Where is tomcat7 installed/What file locations (-L) are installed to for tomcat7? dpkg-query -L tomcat7
package { "tomcat7":
  ensure  => present,
  require => Package["openjdk-6-jdk"],
}

# The admin web applications are installed with context files in /etc/tomcat7/Catalina/localhost
package { "tomcat7-admin":
  ensure  => present,
  require => Package["tomcat7"],
}
