vagrant_puppet
=====================

This project exists to demonstrate learn and experiment using vagrant and puppet provisioning.

- The idea is that master should represent a useful baseline for a typical development server.
- Feature branches will be used to try out and harden additions before merging back into master.

TODO:
- [x] Add some sort of threshold to prevent apt-get update running unnecessarily during repetitive vagrant provisions.
- [x] Get augeas working with puppet provisioner
- [x] Decide on base box selection
- [ ] Dynamic network configuration for the guest. Setting up specific ips in every vagrant file is cumbersome
- [x] update resources to include quotes or not. The documentation on the puppet site demonstrates not using quotes.
- [ ] Add supplemental editor packages. vim, mc what else?
- [x] Set time zone.
- [ ] Set locale.
- [ ] Look at rspec-puppet and puppet-lint
- [ ] Is it possible to update guest additions in a clean way when necessary?
- [ ] Update xml declaration definition to accept and array of files?
- [ ] Reconcile default manifest file default.pp versus site.pp default.pp is the puppet.rb file while site.rb is the default generate file name.
- [ ] Rename the augeas_requirements.pp file to something for more general preconditions.
- [x] Extract apt-get with threshold and default threshold to class and hiera
- [ ] Puppet provisioning scripts seem to take a very long time to run (like 20 minutes sometimes).
- [ ] Extract provisioning commentary into separate meaning markdown files.

TODO: Update manifests to conform to examples in the [puppet style guide](http://docs.puppetlabs.com/guides/style_guide.html).
- [x] Update all puppet strings to be single quoted if they don't need interpolation
- [x] update 'true' to true
- [ ] Refactor shell execs to use the shellquote function.
- [ ] Can run stages be used instead of different manifests files to satisfy augeas?
- [ ] Change onlyif not crap to unless. Augeas only has onlyif no unless.
- [x] Line up =>s

TODO: Install Java deployment/development environment
- [ ] Extract Tomcat stuff into separate manifests and classes.
- [x] Install Java
- [x] Install Tomcat
- [x] Install Tomcat Admin tools
- [x] Configure Tomcat admin web applications user name/passord/group.
- [x] Restart tomcat after user file changes.
- [x] Supply tomcat admin user password at runtime. Went with default hiera values.
- [x] Configure Tomcat startup options in /etc/defaults/tomcat7. JAVA_OPTS for various java -D properties, environment variables
- [x] Configure Tomcat for serving https. Create Java keystore and integrate into tomcat
- [x] Configure Tomcat ports in server.xml
- [ ] Decide on sensible strategy to expose web application directories on the host to the guest
- [x] Add tomcat service restart after tomcat-users.xml change
- [x] Create sensible parameter mechanism for keytool. Went with default hiera values.
- [x] Decide on what directory the keystore should be. Went with /etc/tomcat/.keystore for the default hiera value.

TODO: Install Mysql development environment

Considered direct installation of mysql as this approach was taken for installing tomcat. The mysql puppet module is maintained by puppet labs and is probably the best place to start using modules. During work at a previous organization, I had the module installation process down cold. But, after months and no documentation to reference, I don't remember anything and thus have to start over. Hopefully, it will come back to me.

Good discussion different ways to manage puppet modules.
- [Using Git Submodules With Dynamic Puppet Environments](http://sysadminsjourney.com/content/using-git-submodules-dynamic-puppet-environments/)
- [Puppet With Git Submodules for Fun and Profit](http://blog.thesilentpenguin.com/blog/2012/02/21/puppet-with-git-submodules-for-fun-and-profit/)
- [Managing Puppet modules with librarian-puppet](http://blog.csanchez.org/2013/01/24/managing-puppet-modules-with-librarian-puppet/)

librarian-puppet is awesome but it has some weight associated with it over using git submodules. librarian-puppet takes over the modules directory so local modules need to be stored somewhere else in the directory structure. The upstream librarian was (still?) not maintained and a fork from maelstrom has gained traction. To incorporate librarian-puppet, the librarian-puppet-maelstrom and puppet gems are required. When the dependencies are added, you need look at stepping it up and integrate rvm gemsets and bundler Gemfiles. 

Interesting repositories aimed at simplifying vagrant and puppet manifest management.
- [maestrodev / librarian-puppet (fork)](https://github.com/maestrodev/librarian-puppet)
- [rodjek / librarian-puppet](https://github.com/rodjek/librarian-puppet)
- [narkisr / opskeleton](https://github.com/narkisr/opskeleton)

Steps i did to get librarian-puppet initially working (and need to be better document):
- gem install librarian-puppet-maestrodev
- gem install puppet
- librarian-puppet init
- commit Puppetfile and Puppetfile.lock, .gitignore

TODO:
- [ ] set up rvm gemset
- [ ] set up bundler Gemfile
- [x] Install mysql puppet module (via librarian-puppet).
- [x] Mysql listen on all interfaces
- [ ] Mysql databases created with inodb by default? This is hard coded now and should be more flexible.

- [x] allow mysql root user access on all interfaces? Decided to go with removing most default accounts and adding a alternate root account with a nonstandard name.
- [x] add a single development user and database with full access for application schema creation?
