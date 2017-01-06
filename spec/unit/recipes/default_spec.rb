require 'spec_helper'

describe 'snort::default' do
  context 'Debian Platforms' do
    cached(:chef_run_debian) { ChefSpec::ServerRunner.new(platform: 'debian', version: '8.1').converge('snort::default') }

    it 'creates /var/cache/local/preseeing directory' do
      expect(chef_run_debian).to create_directory('/var/cache/local/preseeding').with(
        owner:     'root',
        group:     'root',
        mode:      '0755',
        recursive: true
      )
    end

    describe 'snort.seed template' do
      let(:snort_seed_template) { '/var/cache/local/preseeding/snort.seed' }

      it 'creates snort.seed preseeding template' do
        expect(chef_run_debian).to create_template(snort_seed_template).with(
          source: 'snort.seed.erb',
          owner:  'root',
          group:  'root',
          mode:   '0755'
        )
      end

      it 'sends run immediately to execute[preseed snort]' do
        expect(chef_run_debian.template(snort_seed_template)).to notify('execute[preseed snort]').to(:run).immediately
      end
    end

    it 'contains executes[preseed snort] with action nothing' do
      execute_resource = chef_run_debian.execute('preseed snort')
      expect(execute_resource).to do_nothing
    end

    it 'installs snort package' do
      expect(chef_run_debian).to install_package('snort')
    end

    it 'installs snort-rules-default package' do
      expect(chef_run_debian).to install_package('snort-rules-default')
    end
  end

  context 'RHEL Platforms' do
    cached(:chef_run_rhel) { ChefSpec::ServerRunner.new(platform: 'centos', version: '7.0').converge('snort::default') }
    let(:daq_rpm)    { "daq-#{chef_run_rhel.node['snort']['rpm']['daq_version']}.x86_64.rpm" }
    let(:snort_rpm)  { "snort-#{chef_run_rhel.node['snort']['rpm']['version']}.x86_64.rpm" }

    it 'includes EPEL' do
      expect(chef_run_rhel).to include_recipe('yum-epel::default')
    end

    it 'creates daq_rpm remote file' do
      expect(chef_run_rhel).to create_remote_file("#{Chef::Config[:file_cache_path]}/#{daq_rpm}").with(
        source:   "https://www.snort.org/downloads/snort/#{daq_rpm}",
        checksum: chef_run_rhel.node['snort']['rpm']['daq_checksum'],
        mode:     '0644'
      )
    end

    it 'installs daq yum package' do
      expect(chef_run_rhel).to install_yum_package('daq').with(
        source: "#{Chef::Config[:file_cache_path]}/#{daq_rpm}"
      )
    end

    it 'creates snort rpm remote file' do
      expect(chef_run_rhel).to create_remote_file("#{Chef::Config[:file_cache_path]}/#{snort_rpm}").with(
        source:   "https://www.snort.org/downloads/snort/#{snort_rpm}",
        checksum: chef_run_rhel.node['snort']['rpm']['checksum'],
        mode:     '0644'
      )
    end

    it 'installs snort yum package' do
      expect(chef_run_rhel).to install_yum_package('snort')
    end
  end
end
