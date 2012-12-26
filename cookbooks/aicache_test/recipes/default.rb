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

  # Installs aicache package.
  bash "install_aicache" do
    user "root"
    cwd "/tmp"
    code <<-EOH
    wget http://aicache.com/aicache.tar
    tar -xf aicache.tar
    cd aicache
    chmod +x install.sh
    ./install.sh
    chmod +x /usr/local/aicache/*.sh
    mkdir /etc/aicache
    mv /usr/local/aicache/*.cfg /etc/aicache
    EOH
  end

rightscale_marker :end

