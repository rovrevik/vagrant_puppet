vagrant_puppet
=====================

This project is to learn, experiment and demonstrate using vagrant and puppet provisioning.

- The idea is that master should represent a useful baseline for a typical development server.
- Feature branches will be used to try out and harden additions before merging back into master.

TODO:
- [ ] Add some sort of threshold to prevent apt-get update running unnecessarily during repetitive vagrant provisions.
- [x] Get augeas working with puppet provisioner
- [x] Decide on base box selection
- [ ] Dynamic network configuration for the guest. Setting up specific ips in every vagrant file is cumbersome
- [x] update resources to include quotes or not. The documentation on the puppet site demonstrates not using quotes.
- [ ] Add supplemental editor packages. vim, mc what else?
- [ ] Set time zone and locale.
- [ ] Look at rspec-puppet and puppet-lint
- [ ] Is it possible to update guest additions in a clean way when necessary?
- [ ] Update xml declaration definition to accept and array of files?

TODO: Update manifests to conform to examples in the [puppet style guide](http://docs.puppetlabs.com/guides/style_guide.html).
- [x] Update all puppet strings to be single quoted if they don't need interpolation
- [x] update 'true' to true
- [ ] Refactor shell execs to use the shellquote function.
- [ ] Can run stages be used instead of different manifests files to satisfy augeas?
- [ ] Change onlyif not crap to unless.
- [ ] Line up =>s

TODO: Install Java deployment/development environment
- [ ] Extract Tomcat stuff into separate manifests and classes.
- [x] Install Java
- [x] Install Tomcat
- [x] Install Tomcat Admin tools
- [x] Configure Tomcat admin web applications user name/passord/group.
- [x] Restart tomcat after user file changes.
- [ ] Supply tomcat admin user password at runtime.
- [x] Configure Tomcat startup options in /etc/defaults/tomcat7. JAVA_OPTS for various java -D properties, environment variables
- [x] Configure Tomcat for serving https. Create Java keystore and integrate into tomcat
- [ ] Configure Tomcat ports in server.xml
- [ ] Decide on sensible strategy to expose web application directories on the host to the guest
- [x] Add tomcat service restart after tomcat-users.xml change
- [ ] Create sensible parameter mechanism for keytool.
- [ ] Decide on what directory the keystore should be.