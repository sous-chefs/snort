require 'spec_helper'

require 'spec_helper'

describe 'Snort Install on Debian 12' do
  let(:runner) { ChefSpec::ServerRunner.new(platform: 'debian', version: '12', step_into: ['snort_install']) }

  it 'converges successfully' do
    expect { :chef_run }.to_not raise_error
  end
end
