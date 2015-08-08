#!/usr/bin/ruby

require 'fileutils'
require 'ipaddr'
require 'yaml'

template_file = 'provisioning/roles/common/files/etchosts.in'
etchosts_file = template_file[0 .. -4]
nodes_file = 'nodes.yaml'

last_dir = Dir.pwd
while ! File.exists?(nodes_file)
    Dir.chdir("..")
    if last_dir == Dir.pwd
        puts "Error: cannot find files"
        exit 1
    end
    last_dir = Dir.pwd
end

if FileUtils.uptodate?(etchosts_file, [nodes_file, template_file])
    exit 0
end

nodes = YAML.load_file(nodes_file)

etchosts_template = File.read(template_file)

hosts = nodes["openstack_nodes"].map { |n| [ IPAddr::new(n["ip"]), n["hostname"] ] }.sort

File.open(etchosts_file, "w") do |fp|
    fp.write(etchosts_template)

    hosts.each do |ip,name|
        fp.write("%s\t%s\n" % [ip, name])
    end
end
