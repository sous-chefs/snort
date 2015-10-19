property :service_name, String

action :nothing do
  # nothing resource listed first to be the default_action
end

action :start do
    service svc_name do
      supports status: true, restart: true
      action :start
    end
end

action :enable do
    service svc_name do
      supports status: true, restart: true
      action :enable
    end
end

action :restart do
    service svc_name do
      supports status: true, restart: true
      action :restart
    end
end

action :reload do
    service svc_name do
      supports status: true, restart: true
      action :reload
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
