# What ruby version is executing on the guest?
# for the "official" vagrant boxes: cat /home/vagrant/postinstall.sh | grep ruby_home
# for Puppet Labs boxes: cat /home/vagrant/ruby.sh | grep RUBY_VERSION=

# What puppet version is executing on the guest?
# The Puppet Labs and Vagrant boxes install puppet with gem. Interesting,
# given that puppet says that installing from gems is "Not Recommended". I
# wonder why? What is the trade off? Is it just more complicated for the user?
# The vagrant box is backed in. (currently 2.7.19)
# The Puppet Labs boxes simply install the latest puppet vi gem. (currently 3.1.1)
# executed: gem list | grep puppet
# or: sudo find / -name  puppet

# Where are the puppet logs on the guest?
# /var/lib/puppet/reports/ and /var/lib/puppet/state/state.yaml

# How does vagrant start puppet apply on the guest?
# TODO

exec { "apt-get update":
  path => "/usr/bin",
}