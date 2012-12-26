#
# Cookbook Name:: lb_aicache
#

include RightScale::LB::Helper

action :install do

  log "  Installing aiCache"

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

end
