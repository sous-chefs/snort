# frozen_string_literal: true

# The combined setup/delete fixture must not queue a restart after deleting its unit.
node.run_state['snort_test_removal'] = true
include_recipe 'test::default'
file '/var/log/snort3/operator.log' do
  content 'Preserve operator and runtime logs'
end
snort_service('sensor') do
  interface 'lo'
  action :delete
end
snort_rules('community') { action :delete }
snort_config('sensor') { action :delete }
snort_install('sensor') { action :remove }

# An unowned rule tree and a later addition to an owned prefix must both survive.
directory '/var/tmp/snort-ownership/rules/local' do
  recursive true
end
file '/var/tmp/snort-ownership/rules/local/sentinel' do
  content 'pre-existing rules'
end
snort_rules 'local' do
  conf_dir '/var/tmp/snort-ownership'
  action :delete
end
directory '/opt/snort/ownership-test' do
  recursive true
end
file '/opt/snort/ownership-test/managed' do
  content 'installed file'
end
ruby_block 'record test prefix ownership' do
  block { SnortCookbook::Ownership.record!('/opt/snort/ownership-test') }
end
file '/opt/snort/ownership-test/sentinel' do
  content 'later operator file'
end
snort_compile 'preserve changed prefix' do
  version '3.0.0.0'
  prefix '/opt/snort/ownership-test'
  action :remove
end
