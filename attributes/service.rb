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

# See conf.rb for setting of home_net and other vars
case node['platform_family']
when 'debian'
  default['snort']['service_name']  = 'snort'
when 'rhel', 'fedora'
  default['snort']['service_name'] = 'snortd'
else
  default['snort']['service_name'] = 'snortd'
end
