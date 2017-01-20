# -*- mode: ruby -*-
# vi: set ft=ruby :

# box name into env var, same script can be used with different boxes. Defaults to win10-edge.
box_name = ENV["box_name"] != nil ? ENV["box_name"].strip : "win10-edge"
boot_timeout = ENV["boot_timeout"] != nil ? ENV["boot_timeout"].strip.to_i : 300

Vagrant.configure(2) do |config|

  config.vm.box = "modern.ie/" + box_name
  config.vm.boot_timeout = boot_timeout

  config.vm.network "forwarded_port", guest: 3389, host: 3389, id: "rdp", auto_correct: true

  config.vm.communicator = "winrm"
  config.winrm.username = "IEUser"
  config.winrm.password = "Passw0rd!"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.customize ["modifyvm", :id, "--vram", "64"]
  end

  config.vm.provision "file", source: "scripts/provision-network-private.ps1", destination: "C:\\Users\\IEUser\\provision-network-private.ps1"
  config.vm.provision "file", source: "scripts/vagrant-onstart.cmd", destination: "C:\\Users\\IEUser\\vagrant-onstart.cmd"

  config.vm.provision "shell", inline: <<-SHELL
powershell -File \\\\VBOXSRV\\vagrant\\hello.ps1

schtasks /Create /SC ONSTART /TN "vagrant-onstart" /TR "C:\\Users\\IEUser\\vagrant-onstart.cmd" /RL HIGHEST /DELAY 0000:20 /F

\\\\VBOXSRV\\vagrant\\VBoxGuestAdditions\\VBoxWindowsAdditions.exe /S

Remove-Item -Recurse -Force C:\\tmp

SHELL

end
