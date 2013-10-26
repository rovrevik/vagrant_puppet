# Where are the puppet logs on the guest?
# /var/lib/puppet/reports/ and /var/lib/puppet/state/state.yaml

exec { "apt-get update":
  path => "/usr/bin",
}