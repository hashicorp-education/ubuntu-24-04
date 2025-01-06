# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.base_mac = "080027F0F51D"
  
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "${MEMORY}"
    vb.cpus = 1
    vb.gui = false
    
    # Recommended settings for ARM64
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
    vb.customize ["modifyvm", :id, "--accelerate3d", "off"]
    vb.customize ["modifyvm", :id, "--audio", "coreaudio"]
    vb.customize ["modifyvm", :id, "--audiocontroller", "hda"]
  end

  config.vm.synced_folder ".", "/vagrant", disabled: true
  
  # SSH settings
  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"
  config.ssh.insert_key = true
end