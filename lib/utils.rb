require 'fileutils'
require 'set'
require 'yaml'

def make_no_proxy_list(nodes)
    names = Set.new(nodes.map { |n| n["hostname"].sub(/^[^.]+\./, ".") })
    return names.to_a().join(",")
end

def generate_ansible_groups(nodes)
    # Create ansible groups based on nodes.
    # There will be groups based on the 'role' defined.

    groups = Hash.new { |h,k| h[k] = [] }

    nodes.each do |node|
        groups[node["role"]] << node["name"]
        groups["all-nodes"] << node["name"]
    end

    return groups
end

class VarsWriter
    def initialize(verbose=false)
        @verbose = verbose
    end

    def write_out_host_var(fp, node)
        if @verbose
            puts "Writing host_var: %s" % [node["name"]]
        end

        data = {
            "node_hostname" => node["hostname"],
        }

        if node["cloud"]
            data["node_cloud"] = node["cloud"]
        elsif node["role"] != "tester"
            raise "Must define 'cloud'"
        end

        fp.write("# Generated, do not edit\n")
        YAML.dump(data, fp)
    end

    def write_out_group_var(fp, group, groups)
        if @verbose
            puts "Writing group_var: %s" % [group]
        end

        data = nil

        case group
        when "keystone-idp"
            data = {
                "keystone_type" => "idp",
                "federate_with" => "shibboleth",
            }
        when "keystone-sp"
            data = {
                "keystone_type" => "sp",
                "federate_with" => "shibboleth",
            }
        else
            ;  # Nothing yet
        end

        fp.write("# Generated, do not edit\n")

        if data
            YAML.dump(data, fp)
        end
    end

    def write_host_vars(nodes, base, nodes_file)
        if @verbose
            puts "Checking %s host vars..." % [base]
        end

        dir_name = File.join(base, "host_vars")
        vars_list = nodes.map { |n| File.join(dir_name, n["name"]) }

        if ! Dir.exists?(dir_name)
            if @verbose
                puts "Making %s" % [dir_name]
            end
            Dir.mkdir(dir_name)
        elsif ! FileUtils.uptodate?(nodes_file, vars_list)
            if @verbose
                puts "Nothing to do, skipping"
            end
            return  # nothing to do
        end

        nodes.each do |n|
            File.open(File.join(dir_name, n["name"]), "w") do |fp|
                write_out_host_var(fp, n)
            end
        end
    end

    def write_group_vars(groups, base, nodes_file)
        if @verbose
            puts "Checking %s group vars" % [base]
        end

        dir_name = File.join(base, "group_vars")
        vars_list = groups.map { |r,_| File.join(dir_name, r) }

        if ! Dir.exists?(dir_name)
            if @verbose
                puts "Making %s" % [dir_name]
            end
            Dir.mkdir(dir_name)
        elsif ! FileUtils.uptodate?(nodes_file, vars_list)
            if @verbose
                puts "Nothing to do, skipping"
            end
            return  # nothing to do
        end

        groups.map do |g,_|
            File.open(File.join(dir_name, g), "w") do |fp|
                write_out_group_var(fp, g, groups)
            end
        end
    end
end
