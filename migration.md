# Migrating from Snort 2 to Snort 3

Cookbook 6 replaces the previous Snort 2 installation and configuration contract.
The resource names remain, but Snort 2 properties and configuration files cannot
be applied unchanged to Snort 3. Chef Infra Client 18+ is required.

## Before upgrading

Back up the current sensor configuration and record its package version, rule
entitlements, capture interface and traffic policy. Stop the old sensor when you
cut over. This cookbook does not silently remove existing distribution packages,
old `snort`/`snortd` services, Snort 2 configuration or historical alert data.
Do not run both sensors against an inline traffic interface unintentionally.

Use the upstream `snort2lua` tool installed beside Snort as a starting point for
converting a customised configuration. Review its output and validate with
`/opt/snort/3.13.2.0/bin/snort -T -c <new-config>`. A successful conversion still needs a traffic acceptance
test for your deployment. Snort 2 shared-object rules and database output plugins
are incompatible with Snort 3.

## Public API changes

| Previous API | Snort 3 replacement |
| --- | --- |
| `snort_install` package/compile selection and old RPM defaults | Pinned source installation; `version`, source URLs and SHA-256 properties |
| `snort_compile.snort_version` | `snort_compile.version` |
| System `/usr/sbin/snort` or `/usr/local/bin/snort` executable | `<prefix>/bin/snort`; no system command link is replaced automatically |
| `database`, `rpm_version`, `install_type`, Debian preseed/interface detection | Removed; output policy belongs in Lua and the service interface is explicit |
| `snort_config` decoder/preprocessor/output configuration hashes | A vendor-policy Lua wrapper, or a custom template using `source` and `cookbook` |
| `site_rules_include` and Snort 2 rule names | `rules`, an array of absolute Snort 3 rule file paths |
| `snort.conf` | `/etc/snort/snort.lua` |
| Default unified2 output under `/var/log/snort` | Plaintext fast alerts under `/var/log/snort3`; choose other Snort 3 loggers in a custom Lua template |
| Upstart or platform-dependent `snort`/`snortd` services | Explicit `snort_service`, default unit `snort3.service` |
| Install implicitly enabled and started the sensor | Declare service `[:create, :enable, :start]` explicitly |
| `community-rules.tar.gz` | `snort3-community-rules.tar.gz` in a named rule directory |

`snort_install` keeps its default `:create` action and adds `:remove`.
`snort_compile` keeps `:compile` and adds `:remove`. Configurations, rules and
services each provide `:delete`. See the resource reference for every property.

## Example wrapper

```ruby
snort_install 'sensor'
snort_rules 'community'
snort_config 'sensor' do
  home_net '10.0.0.0/8'
  rules ['/etc/snort/rules/community/snort3-community.rules']
end
snort_service 'sensor' do
  interface 'eth0'
  action [:create, :enable, :start]
end
```

For another supported source version, provide matching source URLs and checksums
and use its dedicated prefix consistently in install, configuration and service
resources. Build prefixes must be below `/opt/snort/`. Installation removal owns
that prefix and the matching source-build cache. Remove the service before its
executable. Shared build packages, repository configuration and accounts remain.
