vagrant_puppet
=====================

This project is to learn, experiment and demonstrate using vagrant and puppet provisioning.

- The idea is that master should represents a useful baseline for a typical development server.
- Feature branches will be used to try out and harden additions before merging back into master.

TODO:
- [x] Get augeas working with puppet provisioner
- [x] Decide on base box selection
- [ ] Dynamic network configuration for the guest. Setting up specific ips in every vagrant file is cumbersome
- [ ] Install Java deployment/development environment
- [ ] Install Java
- [ ] Install Tomcat
- [ ] Install Tomcat Admin tools
- [ ] Configure Tomcat startup options. JAVA_OPTS for various java -D properties, environment variables
- [ ] Configure Tomcat for serving https. Create Java keystore and integrate into tomcat
- [ ] Configure Tomcat ports in server.xml
- [ ] Decide on sensible strategy to expose web application directories on the host to the guest
