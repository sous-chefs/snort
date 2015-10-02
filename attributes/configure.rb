#
# Cookbook Name:: snort
# Attributes:: default
#
# Copyright 2010-2015, Chef Software, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# These values go into /etc/sysconfig/snort on rhel/fedora systems
# I think they go into /etc/default/snort on debian, but I'm not sure
default['snort']['interface']           = %w(eth0)
default['snort']['confdir']             = '/etc/snort'
default['snort']['config']              = File.join(node['snort']['confdir'], 'snort.conf')
default['snort']['rulesdir']            = File.join(node['snort']['confdir'], 'rules/')
default['snort']['user']                = 'snort'
default['snort']['group']               = 'snort'
default['snort']['pass_first']          = false
default['snort']['logdir']              = '/var/log/snort'
default['snort']['alertmode']           = 'fast'
default['snort']['dump_app']            = true
default['snort']['binary_log']          = true
default['snort']['no_packet_log']       = false
default['snort']['print_interface']     = false
default['snort']['secs']                = 5
default['snort']['syslog']              = '/var/log/messages'
default['snort']['bpf']                 = 'ip or not ip'

default['snort']['output'] = [
  # This is the defualt recommended for most installs, according to source
  'output unified2: filename merged.log, limit 128, nostamp, mpls_event_types, vlan_event_types'
]

# Took these default values from snort.conf as distributed in RPMs from Cisco
default['snort']['home_net']            = 'any'
default['snort']['external_net']        = 'any'
default['snort']['dns_servers']         = '$HOME_NET'
default['snort']['smtp_servers']         = '$HOME_NET'
default['snort']['http_servers']        = '$HOME_NET'
default['snort']['sql_servers']         = '$HOME_NET'
default['snort']['telnet_servers']      = '$HOME_NET'
default['snort']['ssh_servers']         = '$HOME_NET'
default['snort']['ftp_servers']         = '$HOME_NET'
default['snort']['sip_servers']         = '$HOME_NET'
