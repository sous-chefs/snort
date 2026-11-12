# snort_rules

Download and extract a named Snort 3 rule archive into
`<conf_dir>/rules/<resource-name>`. The name allows letters, numbers, underscores
and hyphens. Configure Snort to include the extracted rule files explicitly.

## Actions

* `:create` (default): download and extract the rule archive.
* `:delete`: delete the named extracted directory and cached archive.

## Properties

| Property | Type | Default | Purpose |
| --- | --- | --- | --- |
| `download_type` | String | `community`, or the name for `registered`/`subscriber` | `community`, `registered` or `subscriber` |
| `oinkcode` | String, sensitive | None | Required for private downloads without an override URL |
| `tar_name` | String | `snort3-community-rules.tar.gz` | Archive name; choose a matching Snort 3 archive for private rules |
| `conf_dir` | String | `/etc/snort` | Parent of named rule directories |
| `override_url` | String | None | Download from an explicit distribution URL |
| `checksum` | String | None | Optional SHA-256 for a fixed archive |

## Example

```ruby
snort_rules 'community'
```

Use your own entitlement and secret store for registered/subscriber rules. The
resource hides download URLs from Chef logs. It does not obtain subscriptions.
