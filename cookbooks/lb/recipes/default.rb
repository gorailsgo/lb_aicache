#
# Cookbook Name:: lb
#

rightscale_marker :begin

class Chef::Recipe
  include RightScale::App::Helper
end

log "  Setup default load balancer resource."

# Sets provider for each pool name.
# See cookbooks/app/libraries/helper.rb for the "pool_names" method.
pool_names(node[:lb][:pools]).each do | pool_name |
  lb pool_name do
    provider node[:lb][:service][:provider]
    persist true # Store this resource in node between converges.
    action :nothing
  end
end

# Installs the right_aws gem
r = gem_package "right_aws" do
  gem_binary "/opt/rightscale/sandbox/bin/gem"
  action :nothing
end
r.run_action(:install)

# Reloads newly install gem.
Gem.clear_paths

rightscale_marker :end
