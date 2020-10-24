# -*- mode: ruby -*-
# vi: set ft=ruby :

boot_timeout = ENV["boot_timeout"] != nil ?
  ENV["boot_timeout"].strip.to_i :
  1200

recording_suffix = Time.now.utc.strftime("%Y%m%dT%H%M%S")

Vagrant.configure(2) do |config|

  config.vm.boot_timeout = boot_timeout

  config.vm.communicator = "winrm"
  config.winrm.username = "IEUser"
  config.winrm.password = "Passw0rd!"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.customize [
      "modifyvm", :id,
      "--vram", "64",
      "--graphicscontroller", "vboxsvga",
      "--paravirtprovider", "default",
      "--vrde", "off",
      "--usb", "off",
      "--clipboard-mode", "disabled",
      "--recording", "on"
    ]
    vb.customize [
      "setextradata", :id,
      "GUI/ScaleFactor", "1"
    ]
  end

  config.vm.provision "default", type: "shell" do |s|
      s.powershell_elevated_interactive = true
      s.inline = %{
if ($PSVersionTable.PSVersion.Major -lt 3) {
    echo "Wrong PowerShell version"
    exit 1
}
}
  end

  {
    "win7-ie8" => {
      "port" => 60600,
      "ostype" => "Windows7"
    },
    "win7-ie9" => {
      "port" => 60700,
      "ostype" => "Windows7"
    },
    "win7-ie10" => {
      "port" => 60800,
      "ostype" => "Windows7"
    },
    "win7-ie11" => {
      "port" => 60900,
      "ostype" => "Windows7"
    },
    "win81-ie11" => {
      "port" => 61000,
      "ostype" => "Windows8_64"
    },
    "win10-edge" => {
      "port" => 61100,
      "ostype" => "Windows10_64"
    }
  }.each do |name, attr|
    config.vm.define "#{name}" do |node|

      node.vm.box = "modern.ie/#{name}"

      node.vm.provider "virtualbox" do |vb|
        vb.customize [
          "modifyvm", :id,
          "--ostype", attr['ostype'],
          "--recordingfile", "recordings/#{name}-#{recording_suffix}.webm"
        ]
      end

      node.vm.network "forwarded_port",
        id: "ssh",
        guest: 22,
        host: attr['port'],
        host_ip: "127.0.0.1",
        auto_correct: true
      node.vm.network "forwarded_port",
        id: "winrm",
        guest: 5985,
        host: attr['port'] + 1,
        host_ip: "127.0.0.1",
        auto_correct: true
      node.vm.network "forwarded_port",
        id: "winrm-ssl",
        guest: 5986,
        host: attr['port'] + 2,
        host_ip: "127.0.0.1",
        auto_correct: true

      node.vm.usable_port_range = attr['port'] + 10..attr['port'] + 100

    end
  end

end
