require 'set'

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
