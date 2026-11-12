# frozen_string_literal: true

apt_update 'test packages' if platform_family?('debian')
snort_install 'sensor' do
  build_jobs 4
end
snort_rules 'community' do
  notifies :restart, 'snort_service[sensor]', :delayed unless node.run_state['snort_test_removal']
end
file '/var/tmp/snort3-acceptance.rules' do
  content 'alert udp any any -> $HTTP_SERVERS any (msg:"Sous Chefs Snort 3 acceptance"; content:"sous-chefs-snort3"; sid:1000001; rev:1;)' + "\n"
  mode '0644'
end

file '/var/tmp/snort3-acceptance.pcap' do
  content ['d4c3b2a1020004000000000000000000ffff00000100000000000000000000003b0000003b00000002000000000202000000000108004500002d00010000401166bd0a0000010a0000023039d43100190000736f75732d63686566732d736e6f727433'].pack('H*')
  mode '0644'
end

file '/var/tmp/snort3-outside.pcap' do
  content ['d4c3b2a1020004000000000000000000ffff00000100000000000000000000003b0000003b00000002000000000202000000000108004500002d000100004011aebc0a000001c00002023039d43100190000736f75732d63686566732d736e6f727433'].pack('H*')
  mode '0644'
end

snort_config 'sensor' do
  home_net '10.0.0.0/8'
  rules ['/etc/snort/rules/community/snort3-community.rules', '/var/tmp/snort3-acceptance.rules']
  notifies :restart, 'snort_service[sensor]', :delayed unless node.run_state['snort_test_removal']
end
snort_service 'sensor' do
  interface 'lo'
  action [:create, :enable, :start]
end
