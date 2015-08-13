# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

require 'yaml'
require './lib/utils'

data = YAML.load_file('nodes.yaml')
nodes = data["openstack_nodes"]

groups = generate_ansible_groups(nodes)

writer = VarsWriter.new(verbose=false)

writer.write_host_vars(nodes, "provisioning", 'nodes.yaml')
writer.write_host_vars(nodes, "post-provisioning", 'nodes.yaml')

writer.write_group_vars(groups, "provisioning", "nodes.yaml")
writer.write_group_vars(groups, "post-provisioning", "nodes.yaml")

no_proxy_value = ENV["no_proxy"] + "," + make_no_proxy_list(nodes)

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "ubuntu/trusty64"
    config.ssh.forward_agent = true
    config.ssh.insert_key = false

    # Iterate through entries in YAML file
    (0 .. nodes.length() - 1).each do |i|
        config.vm.define nodes[i]["name"] do |node|
            if Vagrant.has_plugin?("vagrant-proxyconf")
               if ENV["no_proxy"]
                 config.proxy.no_proxy = no_proxy_value
               end
            end

            node.vm.network "private_network", ip: nodes[i]["ip"]
            node.vm.provider :virtualbox do |vb|
                vb.name = nodes[i]["name"]
                vb.memory = nodes[i]["ram"]
            end

            node.vm.provision :ansible do |ansible|
                ansible.host_key_checking = false
                ansible.playbook = "provisioning/dummy.yaml"
                ansible.verbose = "vvvv"
                ansible.groups = groups
                ansible.extra_vars = "nodes.yaml"
            end
        end
    end
end
