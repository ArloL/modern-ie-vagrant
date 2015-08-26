# What is this?

A Vagrantfile for the modern.ie Windows vagrant boxes and some scripts to
setup WinRM.

# How do I use it?

For Windows XP execute `xp-download-prerequisites.sh` on the host first.

Then execute `vagrant up`.

On first boot go to `\\vboxsvr\vagrant` and execute `provision-OS.bat`.

Package the finished box for later using `vagrant package` e.g.

    vagrant package --output "okeeffe-xp-ie6.box" --Vagrantfile Vagrantfile-package

# Sources

* https://gist.github.com/andreptb/57e388df5e881937e62a
* http://blog.syntaxc4.net/post/2014/09/03/windows-boxes-for-vagrant-courtesy-of-modern-ie.aspx
