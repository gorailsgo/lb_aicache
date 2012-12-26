# 
# Cookbook Name:: lb_aicache
#

# Set defaults for HAProxy specific configuration items
set_unless[:lb_aicache][:algorithm] = 'roundrobin'
set_unless[:lb_aicache][:timeout_client] = '60000'
set_unless[:lb_aicache][:timeout_server] = '60000'

