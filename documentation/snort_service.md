# snort_service

Manage an explicit systemd capture process. Creation defines the unit but does
not enable or start it. The process uses a shared `snort` account and network
capture capabilities, rather than running as root.

## Actions

* `:create` (default): create the account, owned log directory and systemd unit.
* `:start`, `:stop`, `:restart`, `:enable`, `:disable`: manage the existing unit.
* `:delete`: stop, disable and delete the unit and its owned log directory.

The shared account is retained after deletion. The configuration, rules and
installation belong to their separate resources.

## Properties

| Property | Type | Default | Purpose |
| --- | --- | --- | --- |
| `service_name` | String | `snort3` | systemd unit name without `.service` |
| `prefix` | String | `/opt/snort/3.13.2.0` | Installed binary prefix |
| `config_path` | String | `/etc/snort/snort.lua` | Lua policy |
| `interface` | String | Required for `:create` | Capture interface; existing-unit actions do not need it |
| `log_dir` | String | `/var/log/snort3` | Owned log directory, removed by `:delete` |
| `options` | Array | `['-q']` | Additional command arguments |

## Example

```ruby
snort_service 'sensor' do
  interface 'eth0'
  action [:create, :enable, :start]
end
```
