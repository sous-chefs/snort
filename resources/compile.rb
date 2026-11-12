# frozen_string_literal: true

unified_mode true
provides :snort_compile
use '_partial/_source'
default_action :compile

action :compile do
  prefix = owned_prefix!
  unless [new_resource.checksum, new_resource.daq_checksum].all? { |digest| digest.to_s.match?(/\A[0-9a-f]{64}\z/i) }
    raise ArgumentError, 'Explicit SHA-256 checksums are required when compiling non-default source versions'
  end
  signature = build_signature
  [prefix, source_cache].each do |path|
    ruby_block "check Snort ownership #{path}" do
      block { SnortCookbook::Ownership.prepare!(path) }
      not_if { SnortCookbook::Ownership.matches?(path) }
    end
  end
  if platform_family?('rhel') && new_resource.enable_build_repositories
    repository_id = build_repository_id
    if platform?('redhat')
      rhsm_repo repository_id
    else
      package 'dnf-plugins-core'
      execute "enable #{repository_id} for Snort builds" do
        command ['dnf', 'config-manager', '--set-enabled', repository_id]
        not_if "dnf -q repolist --enabled | grep -q '^#{repository_id}[[:space:]]'"
      end
    end
    yum_epel 'Snort build dependencies'
  end
  package(new_resource.build_dependencies.empty? ? build_packages : new_resource.build_dependencies)

  directory source_cache do
    mode '0755'
    recursive true
  end

  source_components.each do |component, (url, digest)|
    remote_file "#{source_cache}/#{component}.tar.gz" do
      source url
      checksum digest
      mode '0644'
    end
    archive_file "#{source_cache}/#{component}.tar.gz" do
      destination "#{source_cache}/#{component}"
      strip_components 1
      overwrite true
      not_if { ::File.exist?("#{source_cache}/#{component}/.chef-archive-sha256") && ::File.read("#{source_cache}/#{component}/.chef-archive-sha256") == digest }
    end
    file "#{source_cache}/#{component}/.chef-archive-sha256" do
      content digest
      mode '0644'
    end
  end

  appid_source = "#{source_cache}/snort/src/network_inspectors/appid/appid_debug.cc"
  ruby_block 'correct Snort 3.13.2.0 AppID linkage' do
    block do
      unless Digest::SHA256.file(appid_source).hexdigest == 'b7510d4d5ecdbd848f7342d78e7d35a13dddc824edbe89a77edd0e2252626fea'
        raise ArgumentError, 'Unexpected Snort AppID source; refusing to apply the version-specific linkage correction'
      end
      ::File.write(appid_source, ::File.read(appid_source).sub("\ninline void appid_log(", "\nvoid appid_log("))
    end
    only_if { new_resource.version == '3.13.2.0' && ::File.file?(appid_source) && ::File.read(appid_source).include?("\ninline void appid_log(") }
  end

  bash "build Snort #{new_resource.version} and DAQ #{new_resource.daq_version}" do
    cwd source_cache
    environment('PKG_CONFIG_PATH' => "#{prefix}/lib/pkgconfig")
    code <<~SH
      set -eu
      cd zlib
      ./configure --static --prefix=#{Shellwords.escape(prefix)}
      make -j#{new_resource.build_jobs}
      make install
      cd ../dnet
      ./configure --prefix=#{Shellwords.escape(prefix)} --libdir=#{Shellwords.escape(prefix + '/lib')} --without-python --disable-check
      make -j#{new_resource.build_jobs}
      make install
      cd ../daq
      ./bootstrap
      ./configure --prefix=#{Shellwords.escape(prefix)} --libdir=#{Shellwords.escape(prefix + '/lib')}
      make -j#{new_resource.build_jobs}
      make install
      cd ../snort
      cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=#{Shellwords.escape(prefix)} -DCMAKE_INSTALL_LIBDIR=lib -DDAQ_INCLUDE_DIR=#{Shellwords.escape(prefix + '/include')} -DDAQ_LIBRARIES=#{Shellwords.escape(prefix + '/lib/libdaq.so')} -DDNET_INCLUDE_DIR=#{Shellwords.escape(prefix + '/include')} -DDNET_LIBRARIES=#{Shellwords.escape(prefix + '/lib/libdnet.so')} -DZLIB_INCLUDE_DIR=#{Shellwords.escape(prefix + '/include')} -DZLIB_LIBRARY=#{Shellwords.escape(prefix + '/lib/libz.a')} -DUSE_LIBML_MOCK=ON -DMAKE_HTML_DOC=OFF -DCMAKE_EXE_LINKER_FLAGS=#{Shellwords.escape('-Wl,-rpath,' + prefix + '/lib')}
      cmake --build build --parallel #{new_resource.build_jobs}
      cmake --install build
      #{Shellwords.escape(prefix + '/bin/snort')} -V
      printf '%s' #{Shellwords.escape(signature)} > #{Shellwords.escape(prefix + '/.chef-source-checksums')}
    SH
    not_if { ::File.exist?("#{prefix}/bin/snort") && ::File.exist?("#{prefix}/.chef-source-checksums") && ::File.read("#{prefix}/.chef-source-checksums") == signature }
  end
  [prefix, source_cache].each do |path|
    ruby_block "record Snort ownership #{path}" do
      block { SnortCookbook::Ownership.record!(path) }
      not_if { SnortCookbook::Ownership.matches?(path) }
    end
  end
end

action :remove do
  [owned_prefix!, source_cache].each do |path|
    directory path do
      recursive true
      action :delete
      only_if { SnortCookbook::Ownership.matches?(path) }
    end
  end
  %w(/opt/snort /var/cache/snort3).each do |path|
    directory path do
      action :delete
      only_if { ::Dir.exist?(path) && ::Dir.empty?(path) }
    end
  end
end

action_class do
  include SnortCookbook::Helpers
end
