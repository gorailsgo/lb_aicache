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
  package "openssl" do
    action :install
  end
  package "openssl-devel" do
    action :install
  end

  # Install glib dependency
  bash "install_aicache" do
    user "root"
    cwd "/tmp"
    code <<-EOH
    wget http://ftp.gnome.org/pub/gnome/sources/glib/2.35/glib-2.35.3.tar.xz
    unxz glib-2.35.3.tar.xz
    tar -xf glib-2.35.3.tar
    cd glib-2.35.3.tar
    ./configure
    make -j 4
    make -j 4 install
    EOH
  end

  # Install aiCache software.
  bash "install_aicache" do
    user "root"
    cwd "/tmp"
    code <<-EOH
    aiInstallDir="/usr/local/aicache"
    aiConfigDir="/etc/aicache"
    aiURL="http://aicache.com/aicache.tar"
    wget $aiURL
    tar -xf aicache.tar
    cd aicache
    chmod +x install.sh
    ./install.sh
    mv $aiInstallDir/aicache_https $aiInstallDir/aicache
    chmod +x $aiInstallDir/*.sh
    mkdir $aiConfigDir
    mv $aiInstallDir/*.cfg $aiConfigDir
    cp $aiConfigDir/example.cfg $aiConfigDir/aicache.cfg
    ln -s /lib64/libssl.so.0.9.8e /lib64/libssl.so.0.9.8
    ln -s /lib64/libcrypto.so.0.9.8e /lib64/libcrypto.so.0.9.8
    EOH
  end

  # Install aiCache start/stop/restart script
  template "/etc/init.d/aicache" do
    source "aicache_restart.sh.erb"
  end

  service "aicache" do
    supports :reload => true, :restart => true, :status => true, :start => true, :stop => true
    action :enable
  end

rightscale_marker :end

