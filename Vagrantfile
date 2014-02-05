# -*- mode: ruby -*-
# vi: set ft=ruby :

# this is the directory where the xtuple and xtuple-extensions
# cloned code repositories are located

sourceDir = "/Users/Greg/mobile"

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "precise64"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # Vbguest Plugin
  # We will try to autodetect this path.
  # However, if we cannot or you have a special one you may pass it like:
  # config.vbguest.iso_path = "#{ENV['HOME']}/Downloads/VBoxGuestAdditions.iso"
  # or
  # config.vbguest.iso_path = "http://company.server/VirtualBox/%{version}/VBoxGuestAdditions.iso"

  # set auto_update to false, if you do NOT want to check the correct
  # additions version when booting this machine
  config.vbguest.auto_update = true

  # do NOT download the iso file from a webserver
  config.vbguest.no_remote = true

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :forwarded_port, guest: 443, host: 8443

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network :private_network, ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network :public_network

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder sourceDir, "/home/vagrant/dev"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]

    # Use VBoxManage to customize the VM
    # This line disable hw virtualization and increases memory
    v.customize ["modifyvm", :id, "--memory", "4096"]

    # Via http://blog.liip.ch/archive/2012/07/25/vagrant-and-node-js-quick-tip.html
    v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant", "1"]

    # Debug VM by booting in Gui mode
    #v.gui = true

    # If the host CPU does not have hardware virtualization support,
    # this will disable that setting in VirtualBox - only works on 32-bit OS
    #v.customize ["modifyvm", :id, "--hwvirtex", "off"]
    #v.customize ["modifyvm", :id, "--cpus", "1"]
  end

  # This ensures that the locale is correctly set for Postgres
  config.vm.provision "shell", inline: 'update-locale LC_ALL="en_US.utf8"'

  # Run install script virtual machine is created
  # This forces the script to *not* be run as sudo
  config.vm.provision "shell", path: "vagrant_setup.sh", privileged: "false", binary: "false"

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  #
  # config.vm.provision :chef_solo do |chef|
  #   chef.cookbooks_path = "../my-recipes/cookbooks"
  #   chef.roles_path = "../my-recipes/roles"
  #   chef.data_bags_path = "../my-recipes/data_bags"
  #   chef.add_recipe "mysql"
  #   chef.add_role "web"
  #
  #   # You may also specify custom JSON attributes:
  #   chef.json = { :mysql_password => "foo" }
  # end
end
