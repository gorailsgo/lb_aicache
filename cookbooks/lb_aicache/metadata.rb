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
