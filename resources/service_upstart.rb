provides :snort_service, platform: 'ubuntu' do |node|
  node['platform_version'].to_f < 15.10
end

property :service_name, String

action :start do
  create_init

  service svc_name do
    supports status: true, restart: true
    action :start
  end
end

action :stop do
  service svc_name do
    supports status: true
    action :stop
    only_if { ::File.exist?("/etc/init/#{svc_name}.conf") }
  end
end

action :restart do
  service svc_name do
    action :restart
    supports status: true, restart: true
  end
end

action :enable do
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
    only_if { ::File.exist?("/etc/init/tomcat_#{new_resource.instance_name}.conf") }
  end
end

action_class.class_eval do
  def create_init
    template "/etc/init/#{svc_name}.conf" do
      source 'init_upstart.erb'
      cookbook 'snort'
    end
  end

  # Determine the service_name either by platform or via user override
  def svc_name
    if service_name
      service_name
    else
      case node['platform_family']
      when 'debian'
        'snort'
      else
        'snortd'
      end
    end
  end
end
