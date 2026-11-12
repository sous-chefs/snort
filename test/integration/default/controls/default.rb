# frozen_string_literal: true

control 'snort3-install-configure-capture' do
  title 'Install, configure and run Snort 3'
  desc 'Validate the pinned binary, community rules and running capture service.'
  impact 1.0
  describe command('/opt/snort/3.13.2.0/bin/snort -V') do
    its('exit_status') { should eq 0 }
    its('stdout') { should include '3.13.2.0' }
  end
  describe command('/opt/snort/3.13.2.0/bin/snort -T -c /etc/snort/snort.lua') do
    its('exit_status') { should eq 0 }
  end
  describe file('/etc/snort/rules/community/snort3-community.rules') do
    it { should exist }
    its('size') { should be > 0 }
  end
  describe systemd_service('snort3') do
    it { should be_enabled }
    it { should be_running }
  end
end

control 'snort3-detects-known-offline-packet' do
  title 'Detect a known synthetic packet'
  impact 1.0
  desc 'Process a synthetic PCAP with a local test rule; do not inject traffic into a host network.'
  describe command("/opt/snort/3.13.2.0/bin/snort -q -c /etc/snort/snort.lua -r /var/tmp/snort3-acceptance.pcap -A alert_fast --lua 'alert_fast.file=false'") do
    its('exit_status') { should eq 0 }
    its('stdout') { should include 'Sous Chefs Snort 3 acceptance' }
    its('stdout') { should include '1:1000001:1' }
  end
end

control 'snort3-respects-protected-server-network' do
  title 'Apply HOME_NET to the default protected server variables'
  desc 'The same payload outside HOME_NET must not match the HTTP_SERVERS rule.'
  impact 1.0
  describe command("/opt/snort/3.13.2.0/bin/snort -q -c /etc/snort/snort.lua -r /var/tmp/snort3-outside.pcap -A alert_fast --lua 'alert_fast.file=false'") do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not include 'Sous Chefs Snort 3 acceptance' }
    its('stdout') { should_not include '1:1000001:1' }
  end
end
