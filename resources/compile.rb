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
property :name, String, name_property: true

default_action :compile

action :compile do
  package %w(flex bison make libpcap-dev libdnet-dev libdumbnet-dev libpcre3-dev libghc-zlib-dev)
  directories ['/etc/snort', '/etc/snort/rules', '/usr/local/lib/snort_dynamicrules','/var/log/snort']

  directories.each do |d|
    directory d do
      user 'snort'
      group 'snort'
      mode '5775'
    end
  end

  user 'snort' do
   '/sbin/nologin'
  end

  group 'snort' do
    members 'snort'
  end

  ark 'daq' do
    url new_resource.daq_tar
    :install_with_make
  end

  ark 'snort' do
    url new_resource.snort_tar
    :install_with_make
  end




end
