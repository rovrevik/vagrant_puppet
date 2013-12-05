Managing Puppet modules
-----------------------

Why start using puppet modules.

While on a previous project we were implementing vagrant and puppet and learning it at the same time. The idea of using all the communities puppet modules was the recommend approach and very enticing. Using git submodules was a frustrating process for members of my team. Additionally, the various modules out there in the community varied greatly with respect to robustness. I spent many hours tracing module source attempting to get everything working properly. (It is likely that the time sink was due to ramping up on vagrant and puppet more than the module itself.)

This time around, I followed the recommendation of a trusted colleague and didn't use any modules. Just straight puppet code. This worked well because it allowed me to focus on just puppet for a while. Also, I was provisioning stuff that I already knew exactly how I wanted it installed and there wasn't a module developed and supported by top tier puppet contributor.

Direct installation of MySQL was seriously considered as this approach was taken for installing tomcat. The mysql puppet module is maintained by puppet labs and is probably the best place to start using modules. During work at a previous organization, I had the module installation process down cold. But, after months and no documentation to reference, I don't remember anything and thus have to start over. Hopefully, it will come back to me.

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
