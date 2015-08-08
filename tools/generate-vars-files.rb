#!/usr/bin/ruby

# This is done by the Vagrantfile but if it needs to be run by hand....

require 'yaml'
require './lib/utils.rb'

nodes_file = 'nodes.yaml'

nodes = YAML.load_file(nodes_file)

groups = generate_ansible_groups(nodes["openstack_nodes"])

write_host_vars(nodes["openstack_nodes"], "provisioning", nodes_file)
write_host_vars(nodes["openstack_nodes"], "post-provisioning", nodes_file)

write_group_vars(groups, "provisioning", nodes_file)
write_group_vars(groups, "post-provisioning", nodes_file)
