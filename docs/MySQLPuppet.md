TODO: Install Mysql development environment

TODO:
- [ ] set up rvm gemset
- [ ] set up bundler Gemfile
- [x] Install mysql puppet module (via librarian-puppet).
- [x] Mysql listen on all interfaces
- [ ] Mysql databases created with inodb by default? This is hard coded now and should be more flexible.

- [x] allow mysql root user access on all interfaces? Decided to go with removing most default accounts and adding a alternate root account with a nonstandard name.
- [x] add a single development user and database with full access for application schema creation?
