property :name, String, name_property: true

action :start do
  create_init
  cleanup_old_service if node['init_package'] == 'systemd'

  service svc_name do
    supports status: true, restart: true
    action :start
  end
end

action :stop do
  service svc_name do
    supports status: true
    action :stop
    only_if { ::File.exist?("/etc/init/#{svc_name}.conf") } if node['init_package'] == 'init'
    only_if { ::File.exist?("/etc/systemd/system/#{svc_name}.service") } if node['init_package'] == 'systemd'
  end
end

action :restart do
  service svc_name do
    action :restart
    supports status: true, restart: true
  end
end

action :enable do
  cleanup_old_service if node['init_package'] == 'systemd'
  create_init

  service svc_name do
    supports status: true
    action :enable
  end
end

action :disable do
  service svc_name do
    supports status: true
    action :disable
    only_if { ::File.exist?("/etc/init/tomcat_#{new_resource.instance_name}.conf") } if node['init_package'] == 'init'
    only_if { ::File.exist?("/etc/systemd/system/#{svc_name}.service") } if node['init_package'] == 'systemd'
  end
end

action_class.class_eval do
  def create_init
    if node['init_package'] == 'systemd'

      execute 'Load systemd unit file' do
        command 'systemctl daemon-reload'
        action :nothing
      end

      template "/etc/systemd/system/#{svc_name}.service" do
        source 'init_systemd.erb'
        cookbook 'snort'
        notifies :run, 'execute[Load systemd unit file]', :immediately
      end
    else
      template "/etc/init/#{svc_name}.conf" do
        source 'init_upstart.erb'
        cookbook 'snort'
      end
    end
  end

  def cleanup_old_service
    return unless ::File.exist?('/etc/init.d/snort')
    service 'disable sys-v init snort' do
      service_name svc_name
      action [:stop, :disable]
    end

    file '/etc/init.d/snort' do
      action :delete
    end
  end

  def svc_name
    case node['platform_family']
    when 'debian'
      'snort'
    else
      'snortd'
    end
  end
end
