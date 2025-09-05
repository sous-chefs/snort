property :oinkcode, [String, nil] # Supply this to download registered/subscriber rules
property :tar_name, String, default: 'community-rules.tar.gz' # Override this if you have an Oink code and know the tar you want to download
property :conf_dir, String, default: '/etc/snort'
property :download_type, String, equal_to: %w(community registered subscriber), name_property: true
property :override_url, String

action :create do
  remote_file 'snort tar' do
    source rules_url.to_s
    path ::File.join(Chef::Config[:file_cache_path], 'snort.tar.gz')
  end

  archive_file ::File.join(Chef::Config[:file_cache_path], 'snort.tar.gz') do
    destination ::File.join(new_resource.conf_dir, 'rules')
  end
end

action_class do
  def rules_url
    return new_resource.override_url unless new_resource.override_url.nil?

    if new_resource.download_type.eql? 'community'
      "https://www.snort.org/downloads/#{new_resource.download_type}/#{new_resource.tar_name}"
    else
      log 'Oink Error' do
        level   :error
        message 'You must specify an Oink code to use this rule set'
        only_if { new_resource.oinkcode.nil? }
      end

      "https://www.snort.org/downloads/#{new_resource.download_type}/#{new_resource.tar_name}?oinkcode=#{oinkcode}"
    end
  end
end
