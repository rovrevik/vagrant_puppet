# Where are the puppet logs on the guest?
# /var/lib/puppet/reports/ and /var/lib/puppet/state/state.yaml

# What ruby version is vagrant executing on the guest?
# Vagrant doesn't execute ruby directly. It executes puppet via ssh which uses ruby.
# for the 'official' vagrant boxes: cat /home/vagrant/postinstall.sh | grep ruby_home
# for Puppet Labs boxes: cat /home/vagrant/ruby.sh | grep RUBY_VERSION=
# cat /opt/ruby/bin/puppet | grep '#!'

# What puppet version is executing on the guest?
# The Puppet Labs and Vagrant boxes install puppet with gem. Interesting, given that puppet says that installing from
# gems is 'Not Recommended'. I wonder why? What is the trade off? Is it just more complicated for the user? The vagrant
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

Exec {
  path => ['/usr/bin','/bin'],
}

# Update the timezone. Considered putting this in the requirements manifest but it needs to reference hiera values.
# UbuntuTime >> Ubuntu Time Management >> Changing the Time Zone >> Using the Command Line (unattended)
# https://help.ubuntu.com/community/UbuntuTime#Using_the_Command_Line_.28unattended.29
# Select the timezone string from the /usr/share/zoneinfo directories. Or, use the interactive tzselect command.
$node_timezone = hiera('node_timezone')
exec { node_timezone:
  command => "echo $node_timezone | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata",
  path    => ['/usr/bin','/bin','/usr/sbin/'],  
  unless  => "grep $node_timezone /etc/timezone",
}

# Only execute if apt hasn't been executed in the last 5 minutes. Can't use hiera in this manifest
$apt_get_threshold = 60 * hiera('apt_get_update_threshold_minutes')
$apt_get_output = '/var/puppet_apt_get'
exec { apt_get_update:
  command => "apt-get update > $apt_get_output",
  onlyif  => "echo $(( `date +%s` - `stat -c %X $apt_get_output || echo 0` <= $apt_get_threshold )) | grep 0",
  require => Exec[node_timezone],
}

# Just add a comment to any old file. Fails with Error: Could not find a suitable provider for augeas.
# This did not work initially because the bindings were not visible to the ruby used to execute puppet on the guest.
# This works now because the bindings installed with the ruby-augeas gem are visible in successive manifests executed after the gem is installed.
augeas { hosts_11_15_2013:
  context => '/files/etc/hosts',
  onlyif  => "match #comment[. = 'hosts_11_15_2013'] size == 0",
  changes => [
      'set /files/etc/hosts/#comment[last()+1] hosts_11_15_2013',
  ],
  # require => Package[ruby-augeas],
  # Requirements for augueas are satisfied in the augeas_requirements.pp manifest
}

package { 'openjdk-6-jdk':
  ensure  => present,
  require => Exec[apt_get_update],
}

service { tomcat7:
    ensure  => running,
    enable  => true,
    require => Package[tomcat7],
}

# What packages have tomcat and admin: apt-cache search tomcat admin
# Where is tomcat7 installed/What file locations (-L) are installed to for tomcat7? dpkg-query -L tomcat7
package { tomcat7:
  ensure  => present,
  require => Package['openjdk-6-jdk'],
}

# The admin web applications (manager and host-manager) are installed with context files in /etc/tomcat7/Catalina/localhost
# dpkg-query -L tomcat7-admin | grep /manager.xml
# dpkg-query -L tomcat7-admin | grep /host-manager.xml
package { 'tomcat7-admin':
  ensure  => present,
  require => Package[tomcat7],
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
# set /files/etc/tomcat7/tomcat-users.xml/#comment/[last()+1] xxx
# save

$tomcat_admin_username = hiera('tomcat_admin_username')
$tomcat_admin_password = hiera('tomcat_admin_password')

augeas { tomcat_users_11_20_2013:
  lens    => 'Xml.lns',
  incl    => '/etc/tomcat7/tomcat-users.xml',
  context => '/files/etc/tomcat7/tomcat-users.xml',
  onlyif  => "match tomcat-users/#comment[. = 'tomcat_users_11_20_2013'] size == 0",
  changes => [
    'set tomcat-users/#comment[last()+1] tomcat_users_11_20_2013',

    'set tomcat-users/role[last()+1] #empty',
    'set tomcat-users/role[last()]/#attribute/rolename manager-gui',
    
    'set tomcat-users/role[last()+1] #empty',
    'set tomcat-users/role[last()]/#attribute/rolename admin-gui',
    
    'set tomcat-users/role[last()+1] #empty',
    'set tomcat-users/role[last()]/#attribute/rolename manager',
    
    'set tomcat-users/user[last()+1] #empty',
    "set tomcat-users/user[last()]/#attribute/username $tomcat_admin_username",
    "set tomcat-users/user[last()]/#attribute/password $tomcat_admin_password",
    'set tomcat-users/user[last()]/#attribute/roles manager-gui,admin-gui,manager',
  ],
  notify  => Service[tomcat7],
  require => Replace_matching_line[rewrite_tomcat_users_xml_decl],
}

# apply these changes with what strategy? 
# commenting out the default JAVA_OPT would probably be the best approach but, augeas does not support commenting out
# lines in a straight forward manner. Alternatives to commenting out are deleting the line, renaming the line or just
# resetting the line.
augeas { tomcat7_defaults_11_25_2013:
  context => "/files/etc/default/tomcat7",
  onlyif  => "match #comment[. = 'tomcat7_defaults_11_25_2013'] size == 0",
  changes => [
      'set #comment[last()+1] tomcat7_defaults_11_25_2013',
      "set JAVA_OPTS[last()+1] '\"-Djava.awt.headless=true -Xms512m -Xmx2G -XX:PermSize=512m\"'",
      "set JAVA_OPTS[last()+1] '\"${JAVA_OPTS} -XX:-HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp\"'",
      "set JAVA_OPTS[last()+1] '\"${JAVA_OPTS} -Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n\"'",
  ],
  notify  => Service[tomcat7],
  require => Package[tomcat7],
}

# Configure SSL for tomcat
# Official documentation SSL Configuration HOW-TO: http://tomcat.apache.org/tomcat-7.0-doc/ssl-howto.html

# The following is the process to bring the tomcat server.xml file into augeas.
# set /augeas/load/Xml/incl[last()+1] /etc/tomcat7/server.xml
# set /augeas/load/Xml/lens Xml.lns
# load
# print /files/etc/tomcat7/server.xml
# set /files/etc/tomcat7/server.xml/Server/Service/#comment[last()+1] xxx
# save

$tomcat_keystore_storepass = hiera('tomcat_keystore_storepass')
$tomcat_keystore_keypass = hiera('tomcat_keystore_keypass')
$tomcat_keystore_keystore = hiera('tomcat_keystore_keystore')
$tomcat_keystore_dname = hiera('tomcat_keystore_dname')

exec { tomcat_keytool:
  command => "keytool -genkey -alias tomcat -keyalg RSA --storepass '$tomcat_keystore_storepass' -dname '$tomcat_keystore_dname' -keypass $tomcat_keystore_storepass -keystore '$tomcat_keystore_keystore'",
  path    => '/usr/bin',
  creates => $tomcat_keystore_keystore,
  require => [
    Package['openjdk-6-jdk'],
    Package[tomcat7], # require tomcat7 so that the /etc/tomcat7 directory exists.
  ],
}
->
augeas { tomcat7_server_https_connector:
  lens    => 'Xml.lns',
  incl    => '/etc/tomcat7/server.xml',
  context => '/files/etc/tomcat7/server.xml/Server/Service',
  onlyif  => "match #comment[. = 'tomcat7_server_https_connector'] size == 0",
  changes => [
    'set #comment[last()+1] tomcat7_server_https_connector',
    'set Connector[last()+1] #empty',
    'set Connector[last()]/#attribute/protocol HTTP/1.1',
    'set Connector[last()]/#attribute/port 8443',
    'set Connector[last()]/#attribute/maxThreads 150',
    'set Connector[last()]/#attribute/scheme https',
    'set Connector[last()]/#attribute/secure true',
    'set Connector[last()]/#attribute/SSLEnabled true',
    "set Connector[last()]/#attribute/keystoreFile '$tomcat_keystore_keystore'",
    "set Connector[last()]/#attribute/keystorePass $tomcat_keystore_keypass",
    'set Connector[last()]/#attribute/clientAuth false',
    'set Connector[last()]/#attribute/sslProtocol TLS',
  ],
  notify  => Service[tomcat7],
  require => Replace_matching_line[rewrite_server_xml_decl],
}

if hiera('tomcat_privileged_ports') {
  augeas { tomcat7_defaults_authbind_yes:
    context => "/files/etc/default/tomcat7",
    onlyif  => "match #comment[. = 'tomcat7_defaults_authbind_yes'] size == 0",
    changes => [
        'set #comment[last()+1] tomcat7_defaults_authbind_yes',
        'set AUTHBIND "yes"',
    ],
    require => Package[tomcat7],
  }
  ->
  # This should run for configurations with or without 8080 and/or 8443.
  augeas { tomcat7_server_privileged_ports:
    lens    => 'Xml.lns',
    incl    => '/etc/tomcat7/server.xml',
    context => '/files/etc/tomcat7/server.xml/Server/Service',
    onlyif  => "match #comment[. = 'tomcat7_server_privileged_ports'] size == 0",
    changes => [
      'set #comment[last()+1] tomcat7_server_privileged_ports',
      'set Connector[#attribute/port = "8080"]/#attribute/port 80',
      'set Connector[#attribute/port = "8443"]/#attribute/port 443',
    ],
    notify  => Service[tomcat7],
    require => [
      Replace_matching_line[rewrite_server_xml_decl],
      Augeas[tomcat7_server_https_connector]
    ]
  }
}

# The augeas xml lens fails to parse the default tomcat-users.xml and server.xml file because the xml declaration on
# the first line has double quotes. Which is fine according to the xml specification.
# http://www.w3.org/TR/2008/REC-xml-20081126/#NT-XMLDecl

# Update the tomcat-users.xml file so that augeas is happy. TODO: pull this out after the augeas lens is updated.
# ruby -pi.bak -e 'if $_ =~ /<\?xml(.*'"'"'.*)\?>/; $_ = "#{$&.gsub! %q{'"'"'}, %q{"}}\n" end' tomcat-users.xml

# The definition below is stolen from Puppet 3 Cookbook.
define replace_matching_line($file,$match,$replace) {
  $match_quote_escaped = inline_template("<%= Regexp::escape(@match).gsub!(%q[\']){%q[\'\\\'\']} %>")
  $command = inline_template("ruby -i -p -e 'sub(%r_<%=scope.lookupvar('match_quote_escaped')%>_, '\\''$replace'\\'')' ${file}")
  exec { "exec_ruby_sub $file":
    command   => $command,
    path      => '/opt/ruby/bin:/usr/bin',
    onlyif    => "/bin/grep -E '${match_quote_escaped}' ${file}",
    logoutput => true,
  }
}

# Update the tomcat-users.xml file so that augeas is happy.
replace_matching_line { rewrite_tomcat_users_xml_decl:
  file    => '/etc/tomcat7/tomcat-users.xml',
  match   => '<?xml version=\'1.0\' encoding=\'utf-8\'?>',
  replace => '<?xml version="1.0" encoding="utf-8"?>',
  require => Package[tomcat7],
}

# Update the server.xml file so that augeas is happy.
replace_matching_line { rewrite_server_xml_decl:
  file    => '/etc/tomcat7/server.xml',
  match   => '<?xml version=\'1.0\' encoding=\'utf-8\'?>',
  replace => '<?xml version="1.0" encoding="utf-8"?>',
  require => Package[tomcat7],
}

# Install mysql and supporting tools sufficient for development
# puppetlabs/mysql: https://forge.puppetlabs.com/puppetlabs/mysql
# puppetlabs/puppetlabs-mysql repository: https://github.com/puppetlabs/puppetlabs-mysql
# This link is way outdated: http://puppetlabs.com/blog/module-of-the-week-puppetlabs-mysql-mysql-management
# The mysql/tests/ files are also out of date.

if hiera('mysql_install') {
  $alt_root_username = hiera('mysql_alt_root_username')
  $dev_name = hiera('mysql_dev_name')
  class { 'mysql::server':
    package_name  => hiera('mysql_package'),
    root_password => hiera('mysql_root_password'),
    remove_default_accounts => hiera('mysql_remove_default_accounts'),
    override_options => {
      mysqld => {
        bind_address => hiera('mysql_bind_address'),
        'default-storage-engine' => innodb,
      }
    },

    # http://dev.mysql.com/doc/refman/5.5/en/user-names.html
    # http://dev.mysql.com/doc/refman/5.5/en/default-privileges.html
    # http://dev.mysql.com/doc/refman/5.5/en/connection-access.html
    users => {
      "$alt_root_username@%" => {
        ensure        => present,
        password_hash => mysql_password(hiera('mysql_alt_root_password')),
      },
      "$dev_name@%" => {
        ensure        => present,
        password_hash => mysql_password(hiera('mysql_dev_password')),
      },
    },
    databases => {
      "$dev_name" => {
        ensure  => present,
        charset => 'utf8',
      },
    },
    grants => {
      "$alt_root_username@%" => {
        ensure     => present,
        options    => ['GRANT'],
        privileges => ['ALL'],
        table      => '*.*',
        user       => "$alt_root_username@%",
      },
      "$dev_name@%/$dev_name" => {
        ensure     => present,
        options    => ['GRANT'],
        privileges => ['ALL'],
        table      => "$dev_name.*",
        user       => "$dev_name@%",
      },
    },
  }
}
