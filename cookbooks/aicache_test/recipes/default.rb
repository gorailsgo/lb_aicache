#
# Cookbook Name:: aicache-test
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

rightscale_marker :begin

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
    aiConfigDir="/etc/aicache"
    aiURL="http://aicache.com/aicache.rb.tar"
    curl -sO $aiURL
    tar -xf aicache.rb.tar
    cd aicache
    chmod +x install.sh
    ./install.sh
    mv $aiInstallDir/aicache_https $aiInstallDir/aicache
    chmod +x $aiInstallDir/*.sh
    mkdir $aiConfigDir
    EOH
  end

  # Install aiCache default config
  template "/etc/aicache/aicache.cfg" do
    source "default_config.cfg.erb"
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

rightscale_marker :end

