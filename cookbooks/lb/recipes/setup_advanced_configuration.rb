#
# Cookbook Name:: lb_aicache
#

rightscale_marker :begin

class Chef::Recipe
  include RightScale::App::Helper
end

# See cookbooks/app/libraries/helper.rb for the "pool_names" method.
pool_names(node[:remote_recipe][:pools]).each do |pool_name|
  # See cookbooks/lb_<provider>/providers/default.rb for the "advanced_configs" action.
  lb pool_name do
    action :advanced_configs
  end
end

rightscale_marker :end