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
  default['snort']['home_net']            = "any"
  default['snort']['rpm']['daq_version']  = "2.0.0-1.centos6"
  default['snort']['rpm']['daq_checksum'] = "5aea0ba8e131e97ee1524818417b4200203f7c29450295a8e14a5eb09fb366de"
  default['snort']['rpm']['version']      = "2.9.4-1.centos6"
  default['snort']['rpm']['checksum']     = "d2ec1631a5f9736f8f78729ed220cd035ddec9613622372ce223eb19e0b31909"
when "fedora"
  default['snort']['home_net']            = "any"
  default['snort']['rpm']['daq_version']  = "2.0.0-1.f17"
  default['snort']['rpm']['daq_checksum'] = "656ffa161c724a8bab8a184a67016b478e2d8b1c0c8f53452cb80f5572579c22"
  default['snort']['rpm']['version']      = "2.9.4-1.f17"
  default['snort']['rpm']['checksum']     = "d9ca716c19927e5be9f0057ca0d3157874ef3889171eaf075ab3bc2d16dd8fc1"
else
  default['snort']['home_net'] = "any"
end

default['snort']['database'] = 'none'
