maintainer       "aiCache"
maintainer_email "roman@aicache.com"
license          "All rights reserved"
description      "Simple about_me recipe"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

recipe "about_me::default","Prints my first name and several of my favorite things as output."

# Required #
attribute "about_me/favorite/hobby",
   :display_name => "Hobby",
   :description => "My favorite hobby.",
   :required => "required",
   :recipes => ["about_me::default"]

