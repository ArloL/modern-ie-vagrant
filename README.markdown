# What is this?

Scripts for setting up [WinRM](https://msdn.microsoft.com/en-us/library/windows/desktop/aa384426%28v=vs.85%29.aspx) in the [modern.ie](https://modern.ie/) Windows [Vagrant](https://www.vagrantup.com/) boxes.

# What does it do?

* Bring the Vagrant box up
* Setup WinRM
* Run [UltraDefrag](http://ultradefrag.sourceforge.net)
* Run [SDelete](https://technet.microsoft.com/en-us/sysinternals/sdelete.aspx)
* Package as a new Vagrant box

# How do I use it?

For Windows XP execute `download-prerequisites-xp.sh` on the host first.
For the others execute `download-prerequisites.sh`.

Download the Vagrant box from modern.ie and add it to Vagrant. Then execute the "automated" script for it.

An example for Windows 10 with Edge:

    .\download-prerequisites.sh
    vagrant box add modern.ie/win10-edge "MsEdge - Win10.box"
    .\automated-win10-edge.sh

# Sources

* https://gist.github.com/andreptb/57e388df5e881937e62a
* http://blog.syntaxc4.net/post/2014/09/03/windows-boxes-for-vagrant-courtesy-of-modern-ie.aspx
