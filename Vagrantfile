# -*- mode: ruby -*-
# vi: set ft=ruby :

boot_timeout = ENV["boot_timeout"] != nil ? ENV["boot_timeout"].strip.to_i : 300

Vagrant.configure(2) do |config|

  config.vm.boot_timeout = boot_timeout

  config.vm.network "forwarded_port", guest: 3389, host: 3389, host_ip: "localhost", id: "rdp", auto_correct: true

  config.vm.communicator = "winrm"
  config.winrm.username = "IEUser"
  config.winrm.password = "Passw0rd!"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.customize ["modifyvm", :id, "--vram", "64"]
  end

  config.vm.provision "default", type: "shell" do |s|
      s.powershell_elevated_interactive = true
      s.inline = %{
cd C:\\vagrant\\in-action
.\\provision-checkpsversion.ps1
}
  end

  ["win7-ie8", "win7-ie9", "win7-ie10", "win7-ie11", "win81-ie11", "win10-edge"].each do |name|
    config.vm.define "#{name}" do |node|
      node.vm.box = "modern.ie/#{name}"
    end
  end

end
