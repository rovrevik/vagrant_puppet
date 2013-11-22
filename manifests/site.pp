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
# puppet apply --color=false --manifestdir /tmp/vagrant-puppet/manifests --detailed-exitcodes /tmp/vagrant-puppet/manifests/site.pp || [ $? -eq 2 ]

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

# The admin web applications (manager and host-manager) are installed with context files in /etc/tomcat7/Catalina/localhost
# dpkg-query -L tomcat7-admin | grep /manager.xml
# dpkg-query -L tomcat7-admin | grep /host-manager.xml
package { "tomcat7-admin":
  ensure  => present,
  require => Package["tomcat7"],
}

# enable access to admin gui applications.
# Accessing /manager and /host-manager recommend changes to tomcat-users.xml.
# Documentation included with the tomcat packages recommend similar changes. 
# dpkg-query -L tomcat7 | grep doc/tomcat7/
# ls -la /usr/share/doc/tomcat7/README.Debian.gz note this was actually a link to a file that doesn't exist. Nice!
# The link refers to another nonexistent file in /usr/share/doc/tomcat7-common.
# What created tomcat7-common? The tomcat7-common package. Duh! dpkg -S /usr/share/doc/tomcat7-common
# Finally, the package documentation for tomcat7 recommending change to tomcat-users.xml.
# less /usr/share/doc/tomcat7-common/README.Debian

# Separate recommended changes for tomcat-users.xml
# <role rolename="manager-gui"/>
# <user username="tomcat" password="s3cret" roles="manager-gui"/>
# <role rolename="admin-gui"/>
# <user username="tomcat" password="s3cret" roles="admin-gui"/>
# <role rolename="manager"/>
# <user username="tomcat" password="s3cret" roles="manager"/>
# Combined changes for tomcat-users.xml
# <role rolename="manager-gui"/>
# <role rolename="admin-gui"/>
# <role rolename="manager"/>
# <user username="tomcat" password="s3cret" roles="manager-gui, admin-gui, manager"/>

# The tomcat-users.xml file is not loaded into augeas by default. Arbitrary xml files can be loaded into the augeas and
# is described here http://www.krisbuytaert.be/blog/case-augeas

# The following is the process to bring the tomcat-users.xml file into augeas.
# set /augeas/load/Xml/incl[last()+1] /etc/tomcat7/tomcat-users.xml
# set /augeas/load/Xml/lens Xml.lns
# load
# print /files/etc/tomcat7/tomcat-users.xml

augeas { "tomcat-users_11_20_2013":
  lens    => "Xml.lns",
  incl    => "/etc/tomcat7/tomcat-users.xml",
  context => "/files/etc/tomcat7/tomcat-users.xml",
  onlyif  => "match tomcat-users/#comment[. = 'change tomcat-users_11_20_2013'] size == 0",
  changes => [
    "set tomcat-users/#comment[last()+1] 'change tomcat-users_11_20_2013'",

    "set tomcat-users/role[last()+1] #empty",
    "set tomcat-users/role[last()]/#attribute/rolename manager-gui",
    
    "set tomcat-users/role[last()+1] #empty",
    "set tomcat-users/role[last()]/#attribute/rolename admin-gui",
    
    "set tomcat-users/role[last()+1] #empty",
    "set tomcat-users/role[last()]/#attribute/rolename manager",
    
    "set tomcat-users/user[last()+1] #empty",
    "set tomcat-users/user[last()]/#attribute/username tomcat",
    "set tomcat-users/user[last()]/#attribute/password s3cret",
    "set tomcat-users/user[last()]/#attribute/roles manager-gui,admin-gui,manager",
  ],
  require => [
    Package["tomcat7"],
    replace_matching_line['rewrite_tomcat_users_xml_decl']
  ],
}

# The augeas xml lens fails to parse the default tomcat-users.xml file because the xml declaration on the first line
# has double quotes. Which is fine according to the xml specification.
# http://www.w3.org/TR/2008/REC-xml-20081126/#NT-XMLDecl

# Update the tomcat-users.xml file so that augeas is happy. TODO: pull this out after the augeas lens is
# updated.
# ruby -pi.bak -e 'if $_ =~ /<\?xml(.*'"'"'.*)\?>/; $_ = "#{$&.gsub! %q{'"'"'}, %q{"}}\n" end' tomcat-users.xml

# The definition below is stolen from Puppet 3 Cookbook.
define replace_matching_line($file,$match,$replace) {
  $match_quote_escaped = inline_template("<%= Regexp::escape(@match).gsub!(%q[\']){%q[\'\\\'\']} %>")
  $command = inline_template("ruby -i -p -e 'sub(%r_<%=scope.lookupvar('match_quote_escaped')%>_, '\\''$replace'\\'')' ${file}")
  exec { 'exec_ruby_sub':
    command => $command,
    path => '/opt/ruby/bin:/usr/bin',
    onlyif => "/bin/grep -E '${match_quote_escaped}' ${file}",
    logoutput => "true",
  }
}

replace_matching_line { 'rewrite_tomcat_users_xml_decl':
  file    => '/etc/tomcat7/tomcat-users.xml',
  match   => '<?xml version=\'1.0\' encoding=\'utf-8\'?>',
  replace => '<?xml version="1.0" encoding="utf-8"?>',
  require => Package[tomcat7],
}