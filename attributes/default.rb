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

case node['platform_family']
when 'debian'
  default['snort']['home_net'] = '192.168.0.0/16'
when 'rhel'
  default['snort']['home_net']            = 'any'
  default['snort']['rpm']['daq_version']  = '2.0.4.RH7'
  default['snort']['rpm']['daq_checksum'] = 'ee12d9da5bf3367ec93221fadc7fb6ba7d7bebe1268ecce11d1a66612ada9e1d'
  default['snort']['rpm']['version']      = '2.9.7.6-1.centos7'
  default['snort']['rpm']['checksum']     = '1673fd01f7344cbdd100b7765bfd83663cdd0367097c73ff133dfa998d1b6a46'
when 'fedora'
  default['snort']['home_net']            = 'any'
  default['snort']['rpm']['daq_version']  = '2.0.4.F20'
  default['snort']['rpm']['daq_checksum'] = 'f8d9d546cd7869431189e85dfce83e8e1281d2b816141c5b36ab100e0f0ff12d'
  default['snort']['rpm']['version']      = '2.9.7.2-1.f20'
  default['snort']['rpm']['checksum']     = '3fd6a72551eac1cf8a23915ff10d625b4380888ecdecc592e89efb335bc60ac2'
else
  default['snort']['home_net'] = 'any'
end

default['snort']['database'] = 'none'
