# frozen_string_literal: true

unified_mode true
provides :snort_rules

property :download_type, String, default: lazy { %w(registered subscriber).include?(name) ? name : 'community' }, equal_to: %w(community registered subscriber)
property :oinkcode, String, sensitive: true
property :tar_name, String, default: 'snort3-community-rules.tar.gz'
property :conf_dir, String, default: '/etc/snort'
property :override_url, String
property :checksum, String

action :create do
  raise ArgumentError, 'Rules name must contain only letters, numbers, underscores or hyphens' unless new_resource.name.match?(/\A[a-zA-Z0-9_-]+\z/)
  if !new_resource.override_url && new_resource.download_type != 'community' && !new_resource.oinkcode
    raise ArgumentError, 'oinkcode is required for registered or subscriber rules'
  end
  url = new_resource.override_url || "https://www.snort.org/downloads/#{new_resource.download_type}/#{new_resource.tar_name}"
  url += "?oinkcode=#{new_resource.oinkcode}" if !new_resource.override_url && new_resource.oinkcode
  remote_file "#{Chef::Config[:file_cache_path]}/snort3-rules-#{new_resource.name}.tar.gz" do
    source url
    checksum new_resource.checksum if new_resource.checksum
    mode '0600'
    sensitive true
  end
  archive_file "#{Chef::Config[:file_cache_path]}/snort3-rules-#{new_resource.name}.tar.gz" do
    destination "#{new_resource.conf_dir}/rules/#{new_resource.name}"
    strip_components 1
    overwrite true
    not_if do
      marker = "#{new_resource.conf_dir}/rules/#{new_resource.name}/.chef-archive-sha256"
      archive = "#{Chef::Config[:file_cache_path]}/snort3-rules-#{new_resource.name}.tar.gz"
      ::File.exist?(marker) && ::File.exist?(archive) && ::File.read(marker) == Digest::SHA256.file(archive).hexdigest
    end
  end
  file "#{new_resource.conf_dir}/rules/#{new_resource.name}/.chef-archive-sha256" do
    content lazy { Digest::SHA256.file("#{Chef::Config[:file_cache_path]}/snort3-rules-#{new_resource.name}.tar.gz").hexdigest }
    mode '0644'
  end
end

action :delete do
  raise ArgumentError, 'Invalid rules name' unless new_resource.name.match?(/\A[a-zA-Z0-9_-]+\z/)
  directory "#{new_resource.conf_dir}/rules/#{new_resource.name}" do
    recursive true
    action :delete
  end
  file "#{Chef::Config[:file_cache_path]}/snort3-rules-#{new_resource.name}.tar.gz" do
    action :delete
  end
  ["#{new_resource.conf_dir}/rules", new_resource.conf_dir].each do |path|
    directory path do
      action :delete
      only_if { ::Dir.exist?(path) && ::Dir.empty?(path) }
    end
  end
end
