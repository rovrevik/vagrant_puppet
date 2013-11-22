vagrant_puppet
=====================

This project is to learn, experiment and demonstrate using vagrant and puppet provisioning.

- The idea is that master should represent a useful baseline for a typical development server.
- Feature branches will be used to try out and harden additions before merging back into master.

TODO:
- [x] Get augeas working with puppet provisioner
- [x] Decide on base box selection
- [ ] Dynamic network configuration for the guest. Setting up specific ips in every vagrant file is cumbersome
- [ ] Install Java deployment/development environment
- [x] Install Java
- [x] Install Tomcat
- [x] Install Tomcat Admin tools
- [x] Configure Tomcat admin web applications user name/passord/group.
- [ ] Restart tomcat after user file changes.
- [ ] Supply tomcat admin user password at runtime.
- [ ] Configure Tomcat startup options. JAVA_OPTS for various java -D properties, environment variables
- [ ] Configure Tomcat for serving https. Create Java keystore and integrate into tomcat
- [ ] Configure Tomcat ports in server.xml
- [ ] Decide on sensible strategy to expose web application directories on the host to the guest
- [ ] Add supplemental editor packages. vim, mc what else?
- [ ] Add tomcat service restart after tomcat-users.xml change
