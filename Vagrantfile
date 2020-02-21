# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  # Base Box
  config.vm.box = "ubuntu/bionic64"

  # provision script
  #config.vm.provision :shell, path: "provision/ubuntu-provision.sh"

  # synced folder
  config.vm.synced_folder ".", "/vagrant" #, group: "www-data", owner: "www-data", mount_options: [ "dmode=777", "fmode=777" ]

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  #config.vm.network "private_network", ip: "11.11.13.100"
  #config.vm.network "public_network"

  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
  end
end
