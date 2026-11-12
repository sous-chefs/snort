# frozen_string_literal: true

require 'shellwords'
require 'digest'

module SnortCookbook
  VERSION = '3.13.2.0'
  DAQ_VERSION = '3.0.29'
  SNORT_SHA256 = '298367524a31f0d4725ef12b2b06265b4e76e6545f990ae3dc3b5e4c10f6e0ea'
  DAQ_SHA256 = '136deba78d195163687eb71a6dc81b725c27fde7765b7ef70eb741c371e887a8'
  SOURCE_DEPENDENCIES = {
    'dnet' => ['https://github.com/ofalk/libdnet/archive/refs/tags/libdnet-1.18.2.tar.gz', '95611c6d2703f1772fc01ce74acf4ebcc4bcd4315cede35b343bb90dc43bfd8f'].freeze,
    'zlib' => ['https://github.com/madler/zlib/releases/download/v1.4/zlib-1.4.tar.gz', '02dd159783677a749c04adbdd02b55b8a2bcc7e054f51b76b549199a916ad584'].freeze,
  }.freeze

  module Helpers
    def build_repository_id
      major = node['platform_version'].to_i
      case node['platform']
      when 'redhat'
        "codeready-builder-for-rhel-#{major}-#{node['kernel']['machine']}-rpms"
      when 'oracle'
        "ol#{major}_codeready_builder"
      else
        major == 8 ? 'powertools' : 'crb'
      end
    end

    def build_packages
      case node['platform_family']
      when 'debian'
        %w(autoconf automake libtool pkg-config build-essential cmake flex libfl-dev liblzma-dev bison libpcap-dev libpcre2-dev libhwloc-dev libluajit-5.1-dev libssl-dev zlib1g-dev)
      when 'rhel', 'fedora', 'amazon'
        %w(autoconf automake libtool pkgconf-pkg-config gcc gcc-c++ make cmake flex flex-devel bison libpcap-devel pcre2-devel hwloc-devel luajit-devel xz-devel openssl-devel zlib-devel)
      else
        raise ArgumentError, 'Set build_dependencies for this platform'
      end
    end

    def owned_prefix!
      path = ::File.expand_path(new_resource.prefix)
      unless path.start_with?('/opt/snort/') && path != '/opt/snort/' && !new_resource.prefix.include?('..')
        raise ArgumentError, 'prefix must be a dedicated directory below /opt/snort/'
      end
      path
    end

    def source_cache
      "/var/cache/snort3/#{new_resource.version}-#{new_resource.daq_version}"
    end

    def source_components
      { 'snort' => [new_resource.snort_tar, new_resource.checksum], 'daq' => [new_resource.daq_tar, new_resource.daq_checksum] }.merge(SOURCE_DEPENDENCIES)
    end

    def build_signature
      correction = new_resource.version == '3.13.2.0' ? 'appid-linkage-1' : 'upstream'
      Digest::SHA256.hexdigest(['2', correction, *source_components.values.map(&:last), node['platform'], node['platform_version'], *new_resource.build_dependencies].join(':'))
    end
  end
end
