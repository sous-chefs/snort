# frozen_string_literal: true
snort_install 'none' do
end

snort_service 'snort service' do
  action [:enable, :start]
end

snort_rules 'community'

snort_rules 'registered' do
  oink_code node['oink_code']
  tar_name 'snortrules-snapshot-2976.tar.gz'
end
