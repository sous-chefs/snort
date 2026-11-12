# frozen_string_literal: true

require 'spec_helper'

describe 'snort_install' do
  step_into :snort_install
  platform 'ubuntu', '24.04'
  context 'create' do
    recipe { snort_install 'sensor' }
    it { is_expected.to compile_snort_compile('sensor').with(version: '3.13.2.0', daq_version: '3.0.29', prefix: '/opt/snort/3.13.2.0') }
  end
  context 'remove' do
    recipe { snort_install('sensor') { action :remove } }
    it { is_expected.to remove_snort_compile('sensor') }
  end
end

describe 'snort_compile' do
  step_into :snort_compile
  platform 'ubuntu', '24.04'
  before { allow(SnortCookbook::Ownership).to receive(:matches?).and_return(true) }
  context 'compile' do
    recipe { snort_compile 'sensor' }
    it { is_expected.to install_package(%w(autoconf automake libtool pkg-config build-essential cmake flex libfl-dev liblzma-dev bison libpcap-dev libpcre2-dev libhwloc-dev libluajit-5.1-dev libssl-dev zlib1g-dev)) }
    it { is_expected.to create_remote_file('/var/cache/snort3/3.13.2.0-3.0.29/snort.tar.gz').with(checksum: SnortCookbook::SNORT_SHA256) }
    it { is_expected.to run_bash('build Snort 3.13.2.0 and DAQ 3.0.29') }
  end
  context 'remove' do
    recipe { snort_compile('sensor') { action :remove } }
    it { is_expected.to delete_directory('/opt/snort/3.13.2.0').with(recursive: true) }
    it { is_expected.to delete_directory('/var/cache/snort3/3.13.2.0-3.0.29') }
  end
  context 'remove another version' do
    recipe do
      snort_compile 'sensor' do
        version '3.13.1.0'
        action :remove
      end
    end
    it { is_expected.to delete_directory('/opt/snort/3.13.1.0') }
  end
  context 'unsafe prefix' do
    recipe do
      snort_compile('sensor') do
        prefix '/usr'
        action :remove
      end
    end
    it 'rejects paths not owned by this cookbook' do
      expect { chef_run }.to raise_error(ArgumentError, /dedicated directory/)
    end
  end
end

describe 'Snort RHEL build prerequisites' do
  step_into :snort_compile
  platform 'almalinux', '9'
  before do
    allow(SnortCookbook::Ownership).to receive(:matches?).and_return(true)
    stub_command("dnf -q repolist --enabled | grep -q '^crb[[:space:]]'").and_return(false)
  end
  context 'distribution repositories' do
    recipe { snort_compile 'sensor' }
    it { is_expected.to create_yum_epel('Snort build dependencies') }
    it { is_expected.to run_execute('enable crb for Snort builds').with(command: ['dnf', 'config-manager', '--set-enabled', 'crb']) }
    it 'uses RPM development package names' do
      packages = chef_run.resource_collection.all_resources.grep(Chef::Resource::Package).flat_map(&:package_name)
      expect(packages).to include('flex-devel', 'xz-devel')
      expect(packages).not_to include('libfl-dev', 'liblzma-dev')
    end
  end
  context 'organisation-managed repositories' do
    recipe { snort_compile('sensor') { enable_build_repositories false } }
    it { is_expected.not_to create_yum_epel('Snort build dependencies') }
    it { is_expected.not_to run_execute('enable crb for Snort builds') }
  end
end

describe 'snort_config' do
  step_into :snort_config
  platform 'ubuntu', '24.04'
  context 'create' do
    recipe do
      snort_config('sensor') do
        home_net '10.0.0.0/8'
        rules ['/etc/snort/local.rules']
      end
    end
    it { is_expected.to render_file('/etc/snort/snort.lua').with_content('ips.variables.nets.HOME_NET = "10.0.0.0/8"') }
    it { is_expected.to render_file('/etc/snort/snort.lua').with_content('include /etc/snort/local.rules') }
    it { is_expected.to render_file('/etc/snort/snort.lua').with_content('ips.variables.nets[server] = ips.variables.nets.HOME_NET') }
  end
  context 'delete' do
    recipe { snort_config('sensor') { action :delete } }
    it { is_expected.to delete_file('/etc/snort/snort.lua') }
  end
end

describe 'snort_rules' do
  step_into :snort_rules
  platform 'ubuntu', '24.04'
  before { allow(SnortCookbook::Ownership).to receive(:matches?).and_return(true) }
  context 'community' do
    recipe { snort_rules 'community' }
    it { is_expected.to create_remote_file("#{Chef::Config[:file_cache_path]}/snort3-rules-community.tar.gz").with(source: 'https://www.snort.org/downloads/community/snort3-community-rules.tar.gz', sensitive: true) }
    it { is_expected.to extract_archive_file("#{Chef::Config[:file_cache_path]}/snort3-rules-community.tar.gz").with(destination: '/etc/snort/rules/community.chef-staging', strip_components: 1) }
  end
  context 'delete' do
    recipe { snort_rules('community') { action :delete } }
    it { is_expected.to delete_directory('/etc/snort/rules/community') }
    it 'preserves an archive without a matching owned tree and checksum' do
      expect(chef_run).not_to delete_file("#{Chef::Config[:file_cache_path]}/snort3-rules-community.tar.gz")
    end
  end
  context 'missing credential' do
    recipe { snort_rules('registered') { download_type 'registered' } }
    it 'requires an explicit credential' do
      expect { chef_run }.to raise_error(ArgumentError, /oinkcode is required/)
    end
  end
end

describe 'snort_service' do
  step_into :snort_service
  platform 'ubuntu', '24.04'
  context 'literal systemd arguments' do
    recipe do
      snort_service('sensor') do
        interface 'lo'
        config_path '/etc/snort/${SITE}.lua'
        options ['$HOME', '%literal', 'back\\slash', 'a"quote']
      end
    end
    it 'preserves literal dollar signs and percent signs' do
      expect(chef_run.systemd_unit('snort3.service').content[:Service][:ExecStart]).to include('"/etc/snort/$${SITE}.lua"', '"$$HOME"', '"%%literal"', '"back\\\\slash"', '"a\\"quote"')
    end
  end
  context 'control characters' do
    recipe { snort_service('sensor') { interface "lo\nExecStart=/bin/false" } }
    it 'rejects unit line injection' do
      expect { chef_run }.to raise_error(ArgumentError, /control characters/)
    end
  end
  %i(start stop restart enable disable).each do |operation|
    context operation do
      recipe { snort_service('sensor') { action operation } }
      it 'manages an existing unit without requiring a new capture interface' do
        expect(chef_run.systemd_unit('snort3.service').action).to include operation
      end
    end
  end
  context 'unsafe log deletion' do
    recipe do
      snort_service 'sensor' do
        interface 'lo'
        log_dir '/var/log'
        action :delete
      end
    end
    it 'rejects shared system directories' do
      expect { chef_run }.to raise_error(ArgumentError, /dedicated log directory/)
    end
  end
  context 'create' do
    recipe { snort_service('sensor') { interface 'lo' } }
    it { is_expected.to create_systemd_unit('snort3.service') }
    it { is_expected.to create_directory('/var/log/snort3').with(owner: 'snort', mode: '0750') }
    it 'retains packet capture capabilities while dropping root' do
      expect(chef_run.systemd_unit('snort3.service').content[:Service]).to include(User: 'snort', AmbientCapabilities: 'CAP_NET_RAW CAP_NET_ADMIN')
    end
  end
  context 'delete' do
    recipe do
      snort_service('sensor') do
        interface 'lo'
        action :delete
      end
    end
    it { is_expected.to stop_systemd_unit('snort3.service') }
    it { is_expected.to disable_systemd_unit('snort3.service') }
    it { is_expected.to delete_systemd_unit('snort3.service') }
    it { is_expected.not_to delete_directory('/var/log/snort3') }
  end
end
