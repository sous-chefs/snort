# frozen_string_literal: true

unified_mode true
provides :snort_config

property :prefix, String, default: "/opt/snort/#{SnortCookbook::VERSION}"
property :config_path, String, default: '/etc/snort/snort.lua'
property :home_net, String, default: 'any'
property :external_net, String, default: 'any'
property :rules, Array, default: []
property :source, String, default: 'snort.lua.erb'
property :cookbook, String, default: 'snort'

action :create do
  directory ::File.dirname(new_resource.config_path) do
    recursive true
    mode '0755'
  end

  template new_resource.config_path do
    source new_resource.source
    cookbook new_resource.cookbook
    mode '0644'
    variables(prefix: new_resource.prefix, home_net: new_resource.home_net, external_net: new_resource.external_net, rules: new_resource.rules)
    verify "#{Shellwords.escape(new_resource.prefix + '/bin/snort')} -T -c %{path}"
  end
end

action :delete do
  file new_resource.config_path do
    action :delete
  end
  directory ::File.dirname(new_resource.config_path) do
    action :delete
    only_if { ::Dir.exist?(::File.dirname(new_resource.config_path)) && ::Dir.empty?(::File.dirname(new_resource.config_path)) }
  end
end
