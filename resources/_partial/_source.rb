# frozen_string_literal: true

property :version, String, default: SnortCookbook::VERSION, callbacks: { 'must be a numeric Snort 3 version' => proc { |v| v.match?(/\A3\.\d+\.\d+\.\d+\z/) } }
property :daq_version, String, default: SnortCookbook::DAQ_VERSION, callbacks: { 'must be a numeric DAQ 3 version' => proc { |v| v.match?(/\A3\.\d+\.\d+\z/) } }
property :prefix, String, default: lazy { "/opt/snort/#{version}" }
property :snort_tar, String, default: lazy { "https://github.com/snort3/snort3/archive/refs/tags/#{version}.tar.gz" }
property :daq_tar, String, default: lazy { "https://github.com/snort3/libdaq/archive/refs/tags/v#{daq_version}.tar.gz" }
property :checksum, [String, nil], default: lazy { version == SnortCookbook::VERSION ? SnortCookbook::SNORT_SHA256 : nil }
property :daq_checksum, [String, nil], default: lazy { daq_version == SnortCookbook::DAQ_VERSION ? SnortCookbook::DAQ_SHA256 : nil }
property :build_dependencies, Array, default: []
property :enable_build_repositories, [true, false], default: true
property :build_jobs, Integer, default: 2, callbacks: { 'must be positive' => proc(&:positive?) }
