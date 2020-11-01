# What is this?

Scripts for setting up [WinRM](https://msdn.microsoft.com/en-us/library/windows/desktop/aa384426%28v=vs.85%29.aspx) in the [modern.ie](https://modern.ie/) Windows [Vagrant](https://www.vagrantup.com/) boxes.

# What does it do?

* Bring the Vagrant box up
* Setup WinRM
* Update guest additions
* Package as a new Vagrant box

# How do I use it?

Make sure required software is installed with e.g.
`brew cask install vagrant virtualbox`

## All machines
    
    ./download-prerequisites.sh
    ./download-vms.sh
    ./automated.sh

## A single machine

    ./download-prerequisites.sh
    ./download-vm.sh win10-edge
    ./automated.sh win10-edge

# Sources

* https://gist.github.com/andreptb/57e388df5e881937e62a
* http://blog.syntaxc4.net/post/2014/09/03/windows-boxes-for-vagrant-courtesy-of-modern-ie.aspx
