# frozen_string_literal: true

control 'snort3-owned-artifacts-removed' do
  title 'Remove owned sensor artifacts'
  desc 'Keep shared packages and accounts while removing installation, rules, config, unit and logs.'
  impact 1.0
  %w(/opt/snort/3.13.2.0 /var/cache/snort3/3.13.2.0-3.0.29 /etc/snort/snort.lua /etc/snort/rules/community /etc/systemd/system/snort3.service /var/log/snort3).each do |path|
    describe file(path) do
      it { should_not exist }
    end
  end
end
