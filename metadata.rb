name             'snort'
maintainer       'Joshua Timberman'
maintainer_email 'cookbooks@housepub.org'
license          'Apache 2.0'
description      'Installs Snort IDS packages'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.1.0'

recipe 'snort::default', 'Includes the _install recipe'
recipe 'snort::_install', 'Installs snort packages based on platform'

%w(ubuntu debian redhat centos fedora scientific amazon oracle).each do |os|
  supports os
end

depends 'compat_resource', '>= 12.14.7'

source_url 'https://github.com/jtimberman/snort-cookbook'
issues_url 'https://github.com/jtimberman/snort-cookbook/issues'
