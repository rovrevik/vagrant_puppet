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
- [ ] [Puppet Modules](docs/PuppetModules.md)
- [ ] [Mysql Puppet](docs/MySQLPuppet.md)
- [ ] [Java Stack Puppet](docs/JavaStackPuppet.md)

TODO: Update manifests to conform to examples in the [puppet style guide](http://docs.puppetlabs.com/guides/style_guide.html).
- [x] Update all puppet strings to be single quoted if they don't need interpolation
- [x] update 'true' to true
- [ ] Refactor shell execs to use the shellquote function.
- [ ] Can run stages be used instead of different manifests files to satisfy augeas?
- [ ] Change onlyif not crap to unless. Augeas only has onlyif no unless.
- [x] Line up =>s