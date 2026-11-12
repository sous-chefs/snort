# frozen_string_literal: true

# The combined setup/delete fixture must not queue a restart after deleting its unit.
node.run_state['snort_test_removal'] = true
include_recipe 'test::default'
snort_service('sensor') do
  interface 'lo'
  action :delete
end
snort_rules('community') { action :delete }
snort_config('sensor') { action :delete }
snort_install('sensor') { action :remove }
