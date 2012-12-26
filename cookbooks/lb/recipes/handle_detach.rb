#
# Cookbook Name:: lb
#

rightscale_marker :begin

class Chef::Recipe
  include RightScale::App::Helper
end

# Calls the "detach" action for all pools.
log "Remote recipe executed by do_detach_request"

# See cookbooks/app/libraries/helper.rb for the "pool_names" method.
pool_names(node[:remote_recipe][:pools]).each do |pool_name|
  # See cookbooks/lb_<provider>/providers/default.rb for the "detach" action.
  lb pool_name do
    backend_id node[:remote_recipe][:backend_id]
    action :detach
  end
end

rightscale_marker :end

