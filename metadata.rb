name             'snort'
maintainer       'Sous Chefs'
maintainer_email 'help@sous-chefs.org'
license          'Apache-2.0'
description      'Installs Snort IDS packages'
version          '5.0.2'
chef_version     '>= 15.0'
source_url       'https://github.com/sous-chefs/snort'
issues_url       'https://github.com/sous-chefs/snort/issues'

%w(ubuntu debian redhat centos fedora scientific amazon oracle).each do |os|
  supports os
end

depends 'yum-epel'
