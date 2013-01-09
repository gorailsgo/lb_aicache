# 
# Cookbook Name:: lb_aicache
#

include RightScale::LB::Helper

action :install do

log "Installing aiCache"

  # Install OpenSSL dependencies
  package "openssl-devel" do
    action :install
  end

  # Install aiCache software.
  bash "install_aicache" do
    user "root"
    cwd "/tmp"
    code <<-EOH
    aiInstallDir="/usr/local/aicache"
    aiURL="http://aicache.com/aicache.rb.tar"
    curl -sO $aiURL
    tar -xf aicache.rb.tar
    cd aicache
    chmod +x install.sh
    ./install.sh
    mv $aiInstallDir/aicache_https $aiInstallDir/aicache
    chmod +x $aiInstallDir/*.sh
    EOH
  end

  # Creates /etc/aicache directory.
  directory "/etc/aicache" do
    owner "aicache"
    group "aicache"
    mode 0755
    recursive true
    action :create
  end

  # Creates /etc/aicache/node.d directory.
  directory "/etc/aicache/#{node[:lb][:service][:provider]}.d" do
    owner "aicache"
    group "aicache"
    mode 0755
    recursive true
    action :create
  end

  # Create reload files for aicache
  file "/usr/local/aicache/reload" do
    owner "aicache"
    group "aicache"
    mode "600"
    action :create_if_missing
  end
  file "/usr/local/aicache/reload_success" do
    owner "aicache"
    group "aicache"
    mode "600"
    action :create_if_missing
  end
  file "/usr/local/aicache/reload_fail" do
    owner "aicache"
    group "aicache"
    mode "600"
    action :create_if_missing
  end

  # Install aiCache start/stop/restart script
  template "/etc/init.d/aicache" do
    source "aicache_restart.sh.erb"
    mode "0755"
  end

  service "aicache" do
    supports :reload => true, :restart => true, :status => true, :start => true, :stop => true
    action :enable
  end

  # Install aiCache default config
  template "/etc/aicache/aicache.cfg" do
    source "aicache.cfg.default.erb"
    cookbook "lb_aicache"
    owner "aicache"
    notifies :restart, resources(:service => "aicache")
  end
######################### tested until this line #########################


  # Installs script that concatenates individual server files after the aicache
  # config head into the aicache config.
  cookbook_file "/etc/aicache/aicache-cat.sh" do
    owner "aicache"
    group "aicache"
    mode 0755
    source "aicache-cat.sh"
    cookbook "lb_aicache"
  end

  # Installs the aicache config head which is the part of the aicache config
  # that doesn't change.
  template "/etc/aicache/aicache.cfg.head" do
    source "aicache.cfg.head.erb"
    cookbook "lb_aicache"
    owner "aicache"
    group "aicache"
    mode "0400"
    stats_file="/var/log/aicache/stats-global user aicache group aicache"
    variables(
      :stats_file_line => stats_file,
#      :timeout_client => node[:lb_haproxy][:timeout_client]
    )
  end


  # Installs the aicache config backend which is the part of the aicache config
  # that doesn't change.
#  template "/etc/aicache/aicache.cfg.default_backend" do
#    source "aicache.cfg.default_backend.erb"
#    cookbook "lb_aicache"
#    owner "aicache"
#    group "aicache"
#    mode "0400"
#    backup false
#    variables(
#      :default_backend_line => "#{new_resource.pool_name}_backend"
#    )
#  end

  # Generates the aicache config file.
  execute "/etc/aicache/aicache-cat.sh" do
    user "aicache"
    group "aicache"
    umask 0077
    notifies :start, resources(:service => "aicache")
  end
end


action :add_vhost do

  pool_name = new_resource.pool_name

  # Creates the directory for vhost server files.
  directory "/etc/aicache/#{node[:lb][:service][:provider]}.d/#{pool_name}" do
    owner "aicache"
    group "aicache"
    mode 0755
    recursive true
    action :create
  end

  # Adds current pool to pool_list conf to preserve lb/pools order
  template "/etc/aicache/#{node[:lb][:service][:provider]}.d/pool_list.conf" do
     source "aicache_backend_list.erb"
     owner "aicache"
     group "aicache"
     mode 0600
     backup false
     cookbook "lb_aicache"
     variables(
       :pool_list => node[:lb][:pools]
     )
  end

  # See cookbooks/lb_aicache/definitions/aicache_backend.rb for the definition
  # of "lb_aicache_backend".
  lb_aicache_backend  "create main backend section" do
    pool_name  pool_name
  end

  # Calls the "advanced_configs" action.
#  action_advanced_configs

  # (Re)generates the aicache config file.
  execute "/etc/aicache/aicache-cat.sh" do
    user "aicache"
    group "aicache"
    umask 0077
    action :run
    notifies :reload, resources(:service => "aicache")
  end

  # Tags this server as a load balancer for vhosts it will answer for so app servers
  # can send requests to it.
  # See http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/Chef_Resources#RightLinkTag for the "right_link_tag" resource.
  right_link_tag "loadbalancer:#{pool_name}=lb"

end


action :attach do

  pool_name = new_resource.pool_name

  log "  Attaching #{new_resource.backend_id} / #{new_resource.backend_ip} / #{pool_name}"

  # Creates aicache service.
  service "aicache" do
    supports :reload => true, :restart => true, :status => true, :start => true, :stop => true
    action :nothing
  end

  # Creates the directory for vhost server files.
  directory "/etc/aicache/#{node[:lb][:service][:provider]}.d/#{pool_name}" do
    owner "aicache"
    group "aicache"
    mode 0755
    recursive true
    action :create
  end

  # (Re)generates the aicache config file.
  execute "/etc/aicache/aicache-cat.sh" do
    user "aicache"
    group "aicache"
    umask 0077
    action :nothing
    notifies :reload, resources(:service => "aicache")
  end

  # Creates an individual server file for each vhost and notifies the concatenation script if necessary.
  template ::File.join("/etc/aicache/#{node[:lb][:service][:provider]}.d", pool_name, new_resource.backend_id) do
    source "aicache_server.erb"
    owner "aicache"
    group "aicache"
    mode 0600
    backup false
    cookbook "lb_aicache"
    variables(
      :backend_name => new_resource.backend_id,
      :backend_ip => new_resource.backend_ip,
      :backend_port => new_resource.backend_port,
      :max_conn_per_server => node[:lb][:max_conn_per_server],
      :session_sticky => new_resource.session_sticky,
      :health_check_uri => node[:lb][:health_check_uri]
    )
    notifies :run, resources(:execute => "/etc/aicache/aicache-cat.sh")
  end
end

action :advanced_configs do

  # Creates aicache service.
  service "aicache" do
    supports :reload => true, :restart => true, :status => true, :start => true, :stop => true
    action :nothing
  end

  pool_name = new_resource.pool_name
  pool_name_full =  new_resource.pool_name_full
  log "  Current pool name is #{pool_name}"
  log "  Current FULL pool name is #{pool_name_full}"

  # Template to generate acl sections for aicache config file
  # RESULT EXAMPLE
  # acl url_serverid  path_beg    /serverid
  # acl ns-ss-db1-test-rightscale-com_acl  hdr_dom(host) -i ns-ss-db1.test.rightscale.com
#  template "/etc/aicache/#{node[:lb][:service][:provider]}.d/acl_#{pool_name}.conf" do
#     source "aicache_backend_acl.erb"
#     owner "aicache"
#     group "aicache"
#     mode 0600
#     backup false
#     cookbook "lb_aicache"
#     variables(
#       :pool_name => pool_name,
#       :pool_name_full => pool_name_full
#     )
#  end

  # Template to generate acl sections for aicache config file
  # RESULT EXAMPLE
  # use_backend 2_backend if url_serverid
#  template "/etc/aicache/#{node[:lb][:service][:provider]}.d/use_backend_#{pool_name}.conf" do
#    source "aicache_backend_use.erb"
#    owner "aicache"
#    group "aicache"
#    mode 0600
#    backup false
#    cookbook "lb_aicache"
#    variables(
#      :pool_name => pool_name,
#      :pool_name_full => pool_name_full
#    )
#  end

end


action :attach_request do

  pool_name = new_resource.pool_name

  log "  Attach request for #{new_resource.backend_id} / #{new_resource.backend_ip} / #{pool_name}"

  # Runs remote_recipe for each vhost the app server wants to be part of.
  # See http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/Chef_Resources#RemoteRecipe for the "remote_recipe" resource.
  remote_recipe "Attach me to load balancer" do
    recipe "lb::handle_attach"
    attributes :remote_recipe => {
      :backend_ip => new_resource.backend_ip,
      :backend_id => new_resource.backend_id,
      :backend_port => new_resource.backend_port,
      :pools => pool_name
    }
    recipients_tags "loadbalancer:#{pool_name}=lb"
  end

end


action :detach do

  pool_name = new_resource.pool_name
  backend_id = new_resource.backend_id

  log "  Detaching #{backend_id} from #{pool_name}"

  # Creates aicache service.
  service "aicache" do
    supports :reload => true, :restart => true, :status => true, :start => true, :stop => true
    action :nothing
  end

  # (Re)generates the aicache config file.
  execute "/etc/aicache/aicache-cat.sh" do
    user "aicache"
    group "aicache"
    umask 0077
    action :nothing
    notifies :reload, resources(:service => "aicache")
  end

  # Deletes the individual server file and notifies the concatenation script if necessary.
  file ::File.join("/etc/aicache/#{node[:lb][:service][:provider]}.d", pool_name, backend_id) do
    action :delete
    backup false
    notifies :run, resources(:execute => "/etc/aicache/aicache-cat.sh")
  end

end


action :detach_request do

  pool_name = new_resource.pool_name

  log "  Detach request for #{new_resource.backend_id} / #{pool_name}"

  # Runs remote_recipe for each vhost the app server is part of.
  # See http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/Chef_Resources#RemoteRecipe for the "remote_recipe" resource.
  remote_recipe "Detach me from load balancer" do
    recipe "lb::handle_detach"
    attributes :remote_recipe => {
      :backend_id => new_resource.backend_id,
      :pools => pool_name
    }
    recipients_tags "loadbalancer:#{pool_name}=lb"
  end

end


action :setup_monitoring do

  log "  Setup monitoring for aicache"

  # Installs the aicache collectd script into the collectd library plugins directory.
#  cookbook_file(::File.join(node[:rightscale][:collectd_lib], "plugins", "aicache")) do
#    source "aicache1.4.rb"
#    cookbook "lb_aicache"
#    mode "0755"
#  end

  # Adds a collectd config file for the aicache collectd script with the exec plugin and restart collectd if necessary.
#  template ::File.join(node[:rightscale][:collectd_plugin_dir], "aicache.conf") do
#    backup false
#    source "aicache_collectd_exec.erb"
#    notifies :restart, resources(:service => "collectd")
#    cookbook "lb_aicache"
#  end

#  ruby_block "add_collectd_gauges" do
#    block do
#      types_file = ::File.join(node[:rightscale][:collectd_share], "types.db")
#      typesdb = IO.read(types_file)
#      unless typesdb.include?("gague-age") && typesdb.include?("aicache_sessions")
#        typesdb += <<-EOS
#          aicache_sessions current_queued:GAUGE:0:65535, current_session:GAUGE:0:65535
#          aicache_traffic cumulative_requests:COUNTER:0:200000000, response_errors:COUNTER:0:200000000, health_check_errors:COUNTER:0:200000000
#          aicache_status status:GAUGE:-255:255
#        EOS
#        ::File.open(types_file, "w") { |f| f.write(typesdb) }
#      end
#    end
#  end

end


action :restart do

  log "  Restarting aicache"

  require 'timeout'

  Timeout::timeout(new_resource.timeout) do
    while true
      `service #{new_resource.name} stop`
      break if `service #{new_resource.name} status` !~ /is running/
      Chef::Log.info "service #{new_resource.name} not stopped; retrying in 5 seconds"
      sleep 5
    end

    while true
      `service #{new_resource.name} start`
      break if `service #{new_resource.name} status` =~ /is running/
      Chef::Log.info "service #{new_resource.name} not started; retrying in 5 seconds"
      sleep 5
    end
  end

end
