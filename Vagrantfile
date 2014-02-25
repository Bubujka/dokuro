VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "precise32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"

  config.vm.network :private_network, ip: "192.168.56.66"
  config.vm.synced_folder ".", "/vagrant", nfs: true

  config.vm.provision :shell, :path => "dokuro", :args => 'init'
  if File.exists? File.expand_path "./Vagrant.config"
    require File.expand_path "./Vagrant.config.rb"
  end
end
