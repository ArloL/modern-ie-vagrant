# -*- mode: ruby -*-
# vi: set ft=ruby :

# box name into env var, same script can be used with different boxes. Defaults to win81-ie11.
box_name = box_name = ENV['box_name'] != nil ? ENV['box_name'].strip : 'xp-ie6'
# box repo into env var, so private repos/cache can be used. Defaults to http://aka.ms
box_repo = ENV['box_repo'] != nil ? ENV['box_repo'].strip : 'http://aka.ms'

Vagrant.configure(2) do |config|

  config.vm.box = "modern.ie/" + box_name
  config.vm.box_url = box_repo + "/vagrant-" + box_name
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
