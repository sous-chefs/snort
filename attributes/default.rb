#
# Cookbook Name:: snort
# Attributes:: default
#
# Copyright 2010, Opscode, Inc.
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

case node['platform']
when "ubuntu", "debian"
  default['snort']['home_net'] = "192.168.0.0/16"
when "redhat","centos",
  default['snort']['home_net'] = "any"
  default['daq']['rpm']['version']		= "1.1.1-1.RHEL6"
  default['daq']['rpm']['checksum']		= "5cb19a06fa8d24cff295751ac01bffb2a25dfbf02d002a7d2b54841c56a77760"
  default['snort']['rpm']['version']		= "2.9.3-1.RHEL6"
  default['snort']['rpm']['checksum']		= "1e1bb85f13144ab740dbf071d4564d43bb1d248683a33aa9f2f1cbbcd9d33626"
when "fedora"
  default['snort']['home_net'] = "any"
  default['daq']['rpm']['version']		= "1.1.1-1.F16"
  default['daq']['rpm']['checksum']		= "358ddeb96790955722beb4ee4540781e4d3524fafb0ebe82fe8aead4cb9cd7c2"
  default['snort']['rpm']['version']		= "2.9.3-1.F16"
  default['snort']['rpm']['checksum']		= "b73e2ad696791b672563f24c78f6644209e0b1af03a8fae93d72b8f61ec149f9"
else
  default['snort']['home_net'] = "any"
end

default['snort']['database'] = 'none'
