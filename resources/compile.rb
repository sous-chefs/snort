unified_mode true

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

  remote_file new_resource.daq_tar do
    path "#{daq_path}.tar.gz"
  end

  archive_file "#{daq_path}.tar.gz" do
    path daq_path
    notifies :run, 'execute[Compile DAQ]', :immediately
  end

  remote_file new_resource.snort_tar do
    path "#{snort_path}.tar.gz"
  end

  archive_file "#{snort_path}.tar.gz" do
    path snort_path
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

action_class do
  def daq_path
    "#{Chef::Config[:file_cache_path]}/daq"
  end

  def snort_path
    "#{Chef::Config[:file_cache_path]}/snort"
  end
end
