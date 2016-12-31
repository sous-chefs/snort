#
# Cookbook:: snort
# Recipe:: _install
#
# Copyright:: 2010-2016, Chef Software, Inc
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

  snort_package = case node['snort']['database']
                  when 'none'
                    'snort'
                  when 'mysql'
                    'snort-mysql'
                  when 'postgresql', 'pgsql', 'postgres'
                    'snort-pgsql'
                  end

  directory '/var/cache/local/preseeding' do
    mode '0755'
    recursive true
  end

  template '/var/cache/local/preseeding/snort.seed' do
    source 'snort.seed.erb'
    mode '0755'
    notifies :run, 'execute[preseed snort]', :immediately
  end

  execute 'preseed snort' do
    command 'debconf-set-selections /var/cache/local/preseeding/snort.seed'
    action :nothing
  end

  package snort_package

  package 'snort-rules-default'

when 'rhel', 'fedora'

  # snort needs libnghttp2 from EPEL
  include_recipe 'yum-epel::default' if platform_family?('rhel')

  daq_rpm = "daq-#{node['snort']['rpm']['daq_version']}.x86_64.rpm"

  remote_file "#{Chef::Config[:file_cache_path]}/#{daq_rpm}" do
    source "https://www.snort.org/downloads/snort/#{daq_rpm}"
    checksum node['snort']['rpm']['daq_checksum']
    mode '0644'
  end

  yum_package 'daq' do
    source "#{Chef::Config[:file_cache_path]}/#{daq_rpm}"
    action :install
  end

  snort_rpm = "snort-#{node['snort']['rpm']['version']}.x86_64.rpm"

  remote_file "#{Chef::Config[:file_cache_path]}/#{snort_rpm}" do
    source "https://www.snort.org/downloads/snort/#{snort_rpm}"
    checksum node['snort']['rpm']['checksum']
    mode '0644'
  end

  yum_package 'snort' do
    source "#{Chef::Config[:file_cache_path]}/#{snort_rpm}"
    action :install
  end
end
