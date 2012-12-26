maintainer       "aiCache"
maintainer_email "support@aicache.com"
license          "Copyright aiCache, Inc. All rights reserved."
description      "Installs/Configures lb_aicache"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "1.0.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04"

depends "rightscale"
depends "app"
depends "lb"

recipe "lb_aicache::setup_server", "This loads the required 'lb' resource using the aiCache provider."

attribute "lb_aicache/algorithm",
  :display_name => "Load Balancing Algorithm",
  :description => "The algorithm that the load balancer will use to direct traffic.",
  :required => "optional",
  :default => "roundrobin",
  :choice => ["roundrobin", "leastconn", "source"],
  :recipes => [
    "lb_aicache::setup_server"
  ]

attribute "lb_aicache/timeout_server",
  :display_name => "Server Timeout",
  :description => "The maximum inactivity time on the server side in seconds.",
  :required => "optional",
  :default => "60",
  :recipes => [
    "lb_aicache::setup_server"
  ]

attribute "lb_aicache/timeout_client",
  :display_name => "Client Timeout",
  :description => "The maximum inactivity time on the client side in seconds.",
  :required => "optional",
  :default => "60",
  :recipes => [
    "lb_aicache::setup_server"
  ]
