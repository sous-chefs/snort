# frozen_string_literal: true

unified_mode true
provides :snort_service

property :service_name, String, default: 'snort3', callbacks: { 'must contain only letters, numbers, underscores or hyphens' => proc { |value| value.match?(/\A[a-zA-Z0-9_-]+\z/) } }
property :prefix, String, default: "/opt/snort/#{SnortCookbook::VERSION}"
property :config_path, String, default: '/etc/snort/snort.lua'
property :interface, String
property :log_dir, String, default: '/var/log/snort3'
property :options, Array, default: ['-q']

action :create do
  raise ArgumentError, 'interface is required when creating a capture service' if !new_resource.interface || new_resource.interface.empty?
  log_path = owned_log_directory!
  arguments = ["#{new_resource.prefix}/bin/snort", '-c', new_resource.config_path, '-i', new_resource.interface, '-l', new_resource.log_dir] + new_resource.options
  raise ArgumentError, 'Service arguments must not contain control characters' if arguments.any? { |arg| arg.to_s.match?(/[[:cntrl:]]/) }
  group 'snort' do
    system true
  end
  user 'snort' do
    gid 'snort'
    system true
    shell '/usr/sbin/nologin'
  end
  directory log_path do
    owner 'snort'
    group 'snort'
    mode '0750'
    recursive true
  end
  systemd_unit "#{new_resource.service_name}.service" do
    content({
              Unit: { Description: 'Snort 3 intrusion detection', After: 'network-online.target', Wants: 'network-online.target' },
              Service: {
                Type: 'simple', User: 'snort', Group: 'snort',
                ExecStart: arguments.map { |arg| systemd_argument(arg) }.join(' '),
                AmbientCapabilities: 'CAP_NET_RAW CAP_NET_ADMIN', CapabilityBoundingSet: 'CAP_NET_RAW CAP_NET_ADMIN',
                NoNewPrivileges: true, Restart: 'on-failure'
              },
              Install: { WantedBy: 'multi-user.target' },
            })
    action :create
  end
end

%i(start stop restart enable disable).each do |service_action|
  action service_action do
    systemd_unit "#{new_resource.service_name}.service" do
      action service_action
    end
  end
end

action :delete do
  log_path = owned_log_directory!
  systemd_unit "#{new_resource.service_name}.service" do
    action [:stop, :disable, :delete]
  end
  directory log_path do
    action :delete
    only_if { !::File.symlink?(log_path) && ::Dir.exist?(log_path) && ::Dir.empty?(log_path) }
  end
end

action_class do
  def systemd_argument(argument)
    value = argument.to_s
    return '\\;' if value == ';'
    escaped = value.gsub(/[\\"%$]/) { |char| { '\\' => '\\\\', '"' => '\\"', '%' => '%%', '$' => '$$' }.fetch(char) }
    '"' + escaped + '"'
  end

  def owned_log_directory!
    path = ::File.expand_path(new_resource.log_dir)
    if !new_resource.log_dir.start_with?('/') || new_resource.log_dir.include?('..') || %w(/ /var /var/log /usr /usr/local /opt /etc /home /root /tmp /var/tmp).include?(path)
      raise ArgumentError, 'log_dir must be a dedicated log directory'
    end
    path
  end
end
