# -*- mode: ruby -*-
# vi: set ft=ruby :

boot_timeout = ENV["boot_timeout"] != nil ? ENV["boot_timeout"].strip.to_i : 300

Vagrant.configure(2) do |config|

  config.vm.boot_timeout = boot_timeout

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

  {"win7-ie8": 60600, "win7-ie9": 60700, "win7-ie10": 60800, "win7-ie11": 60900, "win81-ie11": 61000, "win10-edge": 61100}.each do |name,port|
    config.vm.define "#{name}" do |node|
      node.vm.box = "modern.ie/#{name}"
      node.vm.usable_port_range = port..port + 100
    end
  end

end
