# frozen_string_literal: true

unified_mode true
provides :snort_install
use '_partial/_source'

action :create do
  snort_compile new_resource.name do
    version new_resource.version
    daq_version new_resource.daq_version
    prefix new_resource.prefix
    snort_tar new_resource.snort_tar
    daq_tar new_resource.daq_tar
    checksum new_resource.checksum
    daq_checksum new_resource.daq_checksum
    build_dependencies new_resource.build_dependencies
    enable_build_repositories new_resource.enable_build_repositories
    build_jobs new_resource.build_jobs
    action :compile
  end
end

action :remove do
  snort_compile new_resource.name do
    version new_resource.version
    daq_version new_resource.daq_version
    prefix new_resource.prefix
    action :remove
  end
end
