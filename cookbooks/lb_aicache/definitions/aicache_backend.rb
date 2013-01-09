#
# Cookbook Name:: lb_aicache
#

define :lb_aicache_backend, :pool_name => "" do

  backend_name = params[:pool_name] + "_backend"
  stats_uri = "stat_url #{node[:lb][:stats_uri]}" unless "#{node[:lb][:stats_uri]}".empty?
#  stats_auth = "stats auth #{node[:lb][:stats_user]}:#{node[:lb][:stats_password]}" unless \
              "#{node[:lb][:stats_user]}".empty? || "#{node[:lb][:stats_password]}".empty?
  health_uri = "healthcheck #{node[:lb][:health_check_uri]}" unless "#{node[:lb][:health_check_uri]}".empty?
  health_chk = "HTTP 10 8" unless "#{node[:lb][:health_check_uri]}".empty?

  # Creates backend aicache files for the origin it will answer for.
  template ::File.join("/etc/aicache/#{node[:lb][:service][:provider]}.d", "backend_#{params[:pool_name]}.conf") do
    source "aicache_backend.erb"
    cookbook 'lb_aicache'
    owner "aicache"
    group "aicache"
    mode "0400"
    backup false
#    variables(
#      :backend_name_line => backend_name,
#      :stats_uri_line => stats_uri,
#      :stats_auth_line => stats_auth,
#      :health_uri_line => health_uri,
#      :health_check_line => health_chk,
#      :algorithm => node[:lb_aicache][:algorithm],
#      :timeout_server => node[:lb_aicache][:timeout_server]
#    )
  end
end
