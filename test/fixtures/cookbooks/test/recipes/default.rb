# frozen_string_literal: true
snort_install 'none' do
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
