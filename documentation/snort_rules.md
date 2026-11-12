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

Removal uses an ownership manifest of file hashes, symlink targets and directory names. Creation refuses pre-existing populated directories without a matching manifest. Removal preserves an entire tree if files were added, removed or changed outside this cookbook, or ownership cannot be proved. Inspect and archive such content before removing it manually. An interrupted first installation may require manual recovery; the cookbook does not adopt its partial tree.

Updates extract into a guarded staging directory and require a non-empty rules payload before replacing the unchanged owned tree. Failed extraction preserves the installed rules. Failed receipt binding rolls back promotion. Inspect interrupted staging or backup directories manually before retrying.

Ownership also requires trusted UID/permissions on the tree, receipt and ancestors. Receipts are bound to the canonical path and directory identity; copying a receipt does not adopt another directory.
