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

# Just add a comment to any old shellvars file. Fails with Error: Could not find a suitable provider for augeas.
# This does not work because the bindings are not visible to the ruby used to execute puppet on the guest.
augeas { "hosts_11_15_2013":
  context => "/files/etc/hosts",
  onlyif => "match #comment[. = 'change hosts_11_15_2013'] size == 0",
  changes => [
      "set /files/etc/hosts/#comment[last()+1] 'change hosts_11_15_2013'",
  ],
  # require => Package["ruby-augeas"],
  # Requirements for augueas are satisfied in the augeas_requirements.pp manifest
}