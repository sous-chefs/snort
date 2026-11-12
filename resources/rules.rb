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
  rules_path = "#{new_resource.conf_dir}/rules/#{new_resource.name}"
  staging = rules_path + '.chef-staging'
  archive = "#{Chef::Config[:file_cache_path]}/snort3-rules-#{new_resource.name}.tar.gz"
  unchanged = proc do
    marker = "#{rules_path}/.chef-archive-sha256"
    ::File.file?(marker) && ::File.file?(archive) && ::File.read(marker) == Digest::SHA256.file(archive).hexdigest
  end
  ruby_block "check Snort ownership #{rules_path}" do
    block do
      SnortCookbook::Ownership.prepare!(rules_path)
      if ::File.exist?("#{Chef::Config[:file_cache_path]}/snort3-rules-#{new_resource.name}.tar.gz")
        raise ArgumentError, 'Refusing to overwrite an unowned rules archive'
      end
    end
    not_if { SnortCookbook::Ownership.matches?(rules_path) }
  end
  remote_file "#{Chef::Config[:file_cache_path]}/snort3-rules-#{new_resource.name}.tar.gz" do
    source url
    checksum new_resource.checksum if new_resource.checksum
    mode '0600'
    sensitive true
  end
  ruby_block "check Snort staging ownership #{staging}" do
    block { SnortCookbook::Ownership.prepare!(staging) }
    not_if(&unchanged)
  end
  directory staging do
    mode '0755'
    recursive true
    not_if(&unchanged)
  end
  archive_file "#{Chef::Config[:file_cache_path]}/snort3-rules-#{new_resource.name}.tar.gz" do
    destination staging
    strip_components 1
    overwrite true
    not_if(&unchanged)
  end
  file "#{staging}/.chef-archive-sha256" do
    content lazy { Digest::SHA256.file("#{Chef::Config[:file_cache_path]}/snort3-rules-#{new_resource.name}.tar.gz").hexdigest }
    mode '0644'
    not_if(&unchanged)
  end
  ruby_block "promote verified Snort rules #{rules_path}" do
    block do
      unless ::Dir.glob("#{staging}/**/*.rules").any? { |path| ::File.file?(path) && !::File.symlink?(path) }
        raise ArgumentError, 'Replacement archive contains no rules; preserving the installed tree'
      end
      SnortCookbook::Ownership.record!(staging)
      SnortCookbook::Ownership.promote!(staging, rules_path)
    end
    not_if(&unchanged)
  end
end

action :delete do
  raise ArgumentError, 'Invalid rules name' unless new_resource.name.match?(/\A[a-zA-Z0-9_-]+\z/)
  file "#{Chef::Config[:file_cache_path]}/snort3-rules-#{new_resource.name}.tar.gz" do
    action :delete
    only_if do
      rules_path = "#{new_resource.conf_dir}/rules/#{new_resource.name}"
      archive = "#{Chef::Config[:file_cache_path]}/snort3-rules-#{new_resource.name}.tar.gz"
      SnortCookbook::Ownership.matches?(rules_path) && !::File.symlink?(archive) && ::File.file?(archive) && ::File.read("#{rules_path}/.chef-archive-sha256") == Digest::SHA256.file(archive).hexdigest
    end
  end
  directory "#{new_resource.conf_dir}/rules/#{new_resource.name}" do
    recursive true
    action :delete
    only_if { SnortCookbook::Ownership.matches?("#{new_resource.conf_dir}/rules/#{new_resource.name}") }
  end
  ["#{new_resource.conf_dir}/rules", new_resource.conf_dir].each do |path|
    directory path do
      action :delete
      only_if { ::Dir.exist?(path) && ::Dir.empty?(path) }
    end
  end
end
