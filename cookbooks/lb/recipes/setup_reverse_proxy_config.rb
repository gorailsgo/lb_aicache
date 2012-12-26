#
# Cookbook Name:: lb
#

rightscale_marker :begin

# Installs required apache modules
apache_modules = ["proxy_http", "proxy", "proxy_balancer", "proxy_connect"]
apache_modules.each do |m|
  # See https://github.com/rightscale/cookbooks/blob/master/apache2/definitions/apache_module.rb
  # for the "apache_module" definition.
  apache_module m
end

# See https://github.com/rightscale/cookbooks/blob/master/apache2/definitions/web_app.rb
# for the "web_app" definition.
web_app "rightscale-reverse-proxy.vhost" do
  template "rightscale-reverse-proxy.vhost.erb"
  cookbook node[:lb][:service][:provider]
end

rightscale_marker :end
