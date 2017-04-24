property :oinkcode, [String, nil] # Supply this to download registered/subscriber rules
property :tar_name, String, default: 'community-rules.tar.gz' # Override this if you have an Oink code and know the tar you want to download
property :conf_dir, String, default: '/etc/snort'
property :download_type, String, equal_to: %w(community registered subscriber), name_property: true

action :create do

  poise_archive "#{rules_url}" do
    destination "#{new_resource.conf_dir}/rules"
  end
end

action_class.class_eval do
  def rules_url
    case download_type
    when 'registered'
      if new_resource.oinkcode.nil?
        log 'Oink Error' do
          level   :error
          message 'You must specify an Oink code if you are a registered customer & want to use the registered rule set'
        end
      end

      "https://www.snort.org/downloads/#{new_resource.download_type}/#{new_resource.community_rules}?oinkcode=#{oinkcode}"

    when 'community'
      "https://www.snort.org/downloads/#{new_resource.download_type}/#{new_resource.community_rules}"
    when 'subscriber'
      if new_resource.oinkcode.nil?
        log 'Oink Error' do
          level   :error
          message 'You must specify an Oink code if you are a subscriber & want to use the subscriber rule set'
        end
      end
      "https://www.snort.org/downloads/#{new_resource.download_type}/#{new_resource.community_rules}?oinkcode=#{oinkcode}"
    end
  end

end
