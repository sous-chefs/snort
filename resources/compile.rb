#
# Cookbook:: snort
# Resource:: compile
#
# Copyright:: 2017, Webb Agile Solutions Ltd.
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
property :daq_tar, String, required: true
property :snort_tar, String, required: true
property :snort_version, String, required: true
property :daq_version, String, required: true

default_action :compile

action :compile do
  package %w(flex bison make libpcap-dev libdnet-dev libdumbnet-dev libpcre3-dev libghc-zlib-dev)

  user 'snort' do
    shell '/sbin/nologin'
    comment 'SNORT_IDS'
  end

  group 'snort' do
    members 'snort'
  end

  directories = ['/etc/snort', '/etc/snort/rules', '/usr/local/lib/snort_dynamicrules', '/var/log/snort']

  directories.each do |d|
    directory d do
      user 'snort'
      group 'snort'
      mode '5775'
    end
  end

  poise_archive new_resource.daq_tar do
    destination daq_path
    notifies :run, 'execute[Compile DAQ]', :immediately
  end

  poise_archive new_resource.snort_tar do
    destination snort_path
    notifies :run, 'execute[Compile snort]', :immediately
  end

  execute 'Compile DAQ' do
    cwd daq_path
    command './configure && make && make install'
    action :nothing
  end

  execute 'Compile snort' do
    cwd snort_path
    command './configure --enable-sourcefire --disable-open-appid && make && make install && ldconfig'
    action :nothing

    notifies :run, 'execute[Post-compile steps]', :immediately
  end

  execute 'Post-compile steps' do
    cwd snort_path
    command <<-EOH
      ln -s /usr/local/bin/snort /usr/sbin/snort
      cp #{snort_path}/etc/*.conf* /etc/snort
      cp #{snort_path}/etc/*.map* /etc/snort
    EOH
    action :nothing
  end
end

action_class.class_eval do
  def daq_path
    "#{Chef::Config[:file_cache_path]}/daq"
  end

  def snort_path
    "#{Chef::Config[:file_cache_path]}/snort"
  end
end
