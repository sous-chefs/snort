# snort_config

Create a Snort 3 Lua configuration using the vendor's inspection policy, or supply
a complete custom template. Network and rule properties apply to the stock template.

## Actions

* `:create` (default): create the configuration and its parent directory.
* `:delete`: delete the file and remove the parent only when empty.

## Properties

| Property | Type | Default | Purpose |
| --- | --- | --- | --- |
| `prefix` | String | `/opt/snort/3.13.2.0` | Vendor policy installation |
| `config_path` | String | `/etc/snort/snort.lua` | Managed configuration file |
| `home_net` | String | `any` | Protected network expression |
| `external_net` | String | `any` | External network expression |
| `rules` | Array | `[]` | Absolute Snort 3 rule file paths |
| `source` | String | `snort.lua.erb` | Template source |
| `cookbook` | String | `snort` | Cookbook containing the template |

## Example

```ruby
snort_config 'sensor' do
  home_net '10.0.0.0/8'
  rules ['/etc/snort/rules/community/snort3-community.rules']
end
```
