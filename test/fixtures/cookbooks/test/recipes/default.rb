# frozen_string_literal: true
snort_install 'none' do
end

if node['platform_family'] == 'rhel'
  snort_config 'hello' do
    site_rules_include ['community.rules']
    enable_white_list false
    enable_black_list false
  end
end

snort_rules 'community'

# snort_rules 'registered' do
#   oink_code node['oink_code']
#   tar_name 'snortrules-snapshot-2976.tar.gz'
# end
