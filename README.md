# Snort cookbook

Install and manage [Snort 3](https://snort.org/snort3) with explicit Chef custom
resources. This is a breaking upgrade from the Snort 2 cookbook. Read
[migration.md](migration.md) before upgrading an existing sensor.

## Requirements

* Chef Infra Client 18 or newer and systemd.
* Debian 12+, Ubuntu 22.04+, RHEL-compatible 8+, Amazon Linux 2023 and current Fedora.
* A C++17 toolchain, development packages and sufficient memory to compile Snort.
* Network access to the distribution repositories, GitHub and snort.org.

The default builds pinned Snort 3.13.2.0, DAQ 3.0.29, libdnet 1.18.2 and zlib 1.4
into `/opt/snort/3.13.2.0`. Private libraries do not replace system libraries.
The optional LibML model runtime and Hyperscan are not installed by default.

## Usage

```ruby
snort_install 'sensor'
snort_rules 'community' do
  notifies :restart, 'snort_service[sensor]', :delayed
end

snort_config 'sensor' do
  home_net '10.0.0.0/8'
  rules ['/etc/snort/rules/community/snort3-community.rules']
  notifies :restart, 'snort_service[sensor]', :delayed
end

snort_service 'sensor' do
  interface 'eth0' # Choose the sensor's capture interface explicitly.
  action [:create, :enable, :start]
end
```

Installation alone does not start capture. The generated service runs as the
`snort` account with packet-capture capabilities. The configuration uses the
vendor's Snort 3 inspection policy, with explicit network variables and rule files.

## Resources

* [snort_install](documentation/snort_install.md): install or remove the pinned source build.
* [snort_compile](documentation/snort_compile.md): configure source builds directly.
* [snort_config](documentation/snort_config.md): create or delete a Lua configuration.
* [snort_rules](documentation/snort_rules.md): download and remove named rule sets.
* [snort_service](documentation/snort_service.md): manage the systemd unit and capture process.

To remove a sensor, stop and delete its service, delete the managed rule sets and
configuration, then remove the installation. Shared build packages, package
repositories and the `snort` account are retained.

The public community rules do not require an Oinkcode. Registered and subscriber
rules require your own credentials and entitlement. This cookbook does not obtain
subscriptions or redistribute private rules. Use rule archives for Snort 3, not
the Snort 2 community archive or compiled Snort 2 rules.

## Testing

The default Kitchen suite builds Snort, validates its configuration and community
rules, starts the service on isolated loopback and verifies that a synthetic PCAP
triggers a local rule. Two converges check idempotency. The removal suite verifies
that unchanged owned installation, configuration, rules and service artifacts are removed while operator files and logs survive.

```shell
chef install Policyfile.rb
chef exec rspec
KITCHEN_LOCAL_YAML=kitchen.dokken.yml chef exec kitchen test default-ubuntu-2404 --destroy=always
```
