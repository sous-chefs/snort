# frozen_string_literal: true

name             'snort'
maintainer       'Sous Chefs'
maintainer_email 'help@sous-chefs.org'
license          'Apache-2.0'
description      'Installs Snort IDS packages'
version          '6.0.0'
chef_version     '>= 18.0'
source_url       'https://github.com/sous-chefs/snort'
issues_url       'https://github.com/sous-chefs/snort/issues'

supports 'ubuntu', '>= 22.04'
supports 'debian', '>= 12.0'
%w(redhat almalinux rocky oracle).each { |os| supports os, '>= 8.0' }
supports 'centos', '>= 9.0'
supports 'fedora', '>= 43.0'
supports 'amazon', '>= 2023.0'

depends 'yum-epel'
