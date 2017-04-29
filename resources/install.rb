#
# Cookbook:: snort
# Resource:: install
#
# Copyright:: 2010-2017, Chef Software, Inc
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
property :database, String, equal_to: %w(none snort-mysql postgresql pgsql postgres), name_property: true
property :home_net, [String, nil], default: lazy {
  case node['platform_family']
  when 'rhel', 'fedora'
    'any'
  when 'debian'
    '192.168.0.0/16'
  end
}
property :interface, [String, nil]
property :checksum, [String, nil], default: lazy {
  case node['platform_family']
  when 'rhel'
    '4e40da758f49701c8cf418a1b28021f646a7d442357939334411481a760ad8e7'
  when 'fedora'
    '764d9a74afa97147c852bf6bf23f1ad47e159ce68a89c53937acfda5d507cf63'
  end
}
property :daq_checksum, [String, nil], default: lazy {
  case node['platform_family']
  when 'rhel'
    '9e3a45d6b265d3cc7868220eb9152a73803adda7829f150f7c8b5d707c6b4c43'
  when 'fedora'
    '698c31e5381d572e3b43c922e2471acdfe1027c0c545abdb7d0a5dd751198ffd'
  end
}
property :rpm_version, String, default: lazy { snort_version }
property :snort_version, String, default: '2.9.9.0-1'
property :daq_version, String, default: '2.0.6-1'
property :install_type, String, default: 'package', equal_to: %w( package compile )
property :daq_tar, [String, nil] # If you want to override the daq_tar pass in the full url e.g. https://www.snort.org/downloads/snort/daq-2.0.6.tar.gz
property :snort_tar, [String, nil]

action :create do
  with_run_context :parent do
    snort_service 'snort' do
      action :enable
    end
  end

  if new_resource.install_type.eql? 'compile'
    snort_compile '' do
      daq_tar new_resource.daq_tar.nil? ? "https://www.snort.org/downloads/snort/daq-#{new_resource.daq_version}.tar.gz" : new_resource.daq_tar
      snort_tar new_resource.snort_tar.nil? ? "https://www.snort.org/downloads/snort/snort-#{new_resource.snort_version}.tar.gz" : new_resource.snort_tar
      snort_version new_resource.snort_version
      daq_version new_resource.daq_version
      notifies :start, 'snort_service[snort]', :delayed
    end
  else
    case node['platform_family']
    when 'debian'
      directory '/var/cache/local/preseeding' do
        mode '0755'
        recursive true
      end

      template '/var/cache/local/preseeding/snort.seed' do
        source 'snort.seed.erb'
        cookbook 'snort'
        mode '0755'
        variables(
          home_net: new_resource.home_net,
          interface: new_resource.interface.nil? ? default_interface : new_resource.interface, # Use computed interface if we haven't passed one in
        )
        notifies :run, 'execute[preseed snort]', :immediately
      end

      execute 'preseed snort' do
        command 'debconf-set-selections /var/cache/local/preseeding/snort.seed'
        action :nothing
      end

      package snort_package

      package 'snort-rules-default' do
        notifies :start, 'snort_service[snort]', :delayed
      end

    when 'rhel', 'fedora'
      # snort needs libnghttp2 from EPEL
      include_recipe 'yum-epel::default' if platform_family?('rhel')

      daq_rpm = "daq-#{new_resource.daq_version}#{package_suffix}.x86_64.rpm"

      remote_file "#{Chef::Config[:file_cache_path]}/#{daq_rpm}" do
        source "https://www.snort.org/downloads/snort/#{daq_rpm}"
        checksum new_resource.daq_checksum
        mode '0644'
      end

      package 'daq' do
        source "#{Chef::Config[:file_cache_path]}/#{daq_rpm}"
      end

      snort_rpm = "snort-#{new_resource.rpm_version + package_suffix}.x86_64.rpm"

      remote_file "#{Chef::Config[:file_cache_path]}/#{snort_rpm}" do
        source "https://www.snort.org/downloads/snort/#{snort_rpm}"
        checksum new_resource.checksum
        mode '0644'
      end

      package 'snort' do
        source "#{Chef::Config[:file_cache_path]}/#{snort_rpm}"
        notifies :start, 'snort_service[snort]', :delayed
      end
    end
  end
end

action_class.class_eval do
  def package_suffix
    if node['platform'] == 'fedora'
      '.f21'
    else
      '.centos7'
    end
  end

  def snort_package
    case new_resource.database
    when 'none'
      'snort'
    when 'mysql'
      'snort-mysql'
    when 'postgresql', 'pgsql', 'postgres'
      'snort-pgsql'
    end
  end

  def default_interface
    require 'mixlib/shellout'

    default_interface = Mixlib::ShellOut.new("route | grep default | awk '{print $8}'")
    default_interface.run_command.stdout.strip!
  end
end
