# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

# Require YAML module
require 'yaml'

# Read YAML file with node details
nodes = YAML.load_file('nodes.yaml')

# Create ansible groups based on nodes.
# There will be groups based on the 'role' defined.

groups = Hash.new { |h,k| h[k] = [] }

nodes.each do |node|
    groups[node["role"]] << node["name"]
    groups["all-nodes"] << node["name"]
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "ubuntu/trusty64"
    config.ssh.forward_agent = true

    # Iterate through entries in YAML file
    nodes.each do |nodes|
        config.vm.define nodes["name"] do |node|
            if Vagrant.has_plugin?("vagrant-proxyconf")
               if ENV["no_proxy"]
                 config.proxy.no_proxy = ENV["no_proxy"] +",#{nodes['ip']}"
               end
            end

            node.vm.network "private_network", ip: nodes["ip"]
            node.vm.provider :virtualbox do |vb|
                vb.name = nodes["name"]
                vb.memory = nodes["ram"]
            end

            node.vm.provision :ansible do |ansible|
                ansible.host_key_checking = false
                ansible.playbook = "provisioning/devstack.yml"
                ansible.verbose = "vvv"
                ansible.groups = groups
            end
        end
    end
end
