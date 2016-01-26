# -*- mode: ruby -*-
# vi: set ft=ruby :

# box name into env var, same script can be used with different boxes. Defaults to win10-edge.
box_name = box_name = ENV['box_name'] != nil ? ENV['box_name'].strip : 'win10-edge'

Vagrant.configure(2) do |config|

  config.vm.box = "modern.ie/" + box_name
  config.vm.boot_timeout = 1200

  config.vm.network "forwarded_port", guest: 3389, host: 3389, id: "rdp", auto_correct: true

  config.vm.communicator = "winrm"
  config.winrm.username = "IEUser"
  config.winrm.password = "Passw0rd!"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
  end

  config.vm.provision "shell", inline: "powershell -File C:\\vagrant\\compact.ps1"

end
