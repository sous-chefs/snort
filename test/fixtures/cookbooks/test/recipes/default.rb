# frozen_string_literal: true
snort_install 'none' do
  install_type node['platform'] == 'debian' ? 'compile' : 'package'
  daq_version '2.0.6' if node['platform'] == 'debian' # They've patched the rpms adding a "-1" suffix
  snort_version '2.9.9.0' if node['platform'] == 'debian'
end

snort_config 'hello' do
  site_rules_include ['community.rules']
  enable_white_list false
  enable_black_list false
end

snort_rules 'community' do
  override_url node['community_rules_url']
end

# snort_rules 'registered' do
#   oink_code node['oink_code']
#   tar_name 'snortrules-snapshot-2976.tar.gz'
# end
