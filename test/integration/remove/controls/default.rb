# frozen_string_literal: true

control 'snort3-owned-artifacts-removed' do
  title 'Remove owned sensor artifacts'
  desc 'Remove unchanged owned artifacts and retain operator files and logs.'
  impact 1.0
  %w(/opt/snort/3.13.2.0 /var/cache/snort3/3.13.2.0-3.0.29 /etc/snort/snort.lua /etc/snort/rules/community /etc/systemd/system/snort3.service).each do |path|
    describe file(path) do
      it { should_not exist }
    end
  end
  %w(/opt/snort/ownership-test/managed /opt/snort/ownership-test/sentinel /var/tmp/snort-ownership/rules/local/sentinel /var/log/snort3/operator.log).each do |path|
    describe file(path) do
      it { should exist }
    end
  end
end
