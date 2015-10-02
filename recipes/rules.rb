#
# Cookbook Name:: snort
# Recipe:: default
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

remote_file "#{Chef::Config[:file_cache_path]}/snort_rules.tar.gz" do
  source "#{node['snort']['registered_rules_url']}?oinkcode=#{node['snort']['oinkcode']}"
  mode '0644'
end

execute "extract snort registered rules" do
  command "tar -xzf #{Chef::Config[:file_cache_path]}/snort_rules.tar.gz -C"\
    " #{node['snort']['confdir']} rules"
  not_if { ::File.exist?(
    ::File.join(node['snort']['confdir'], 'rules', 'VRT-License.txt')
  ) }
end
