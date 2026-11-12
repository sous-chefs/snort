# snort_install

Build pinned Snort 3 and its private source dependencies. The installation is
separate from configuration, rule downloads and packet capture.

## Actions

* `:create` (default): build and install.
* `:remove`: delete the owned versioned prefix and its build cache. Stop the
  sensor service first. Retain shared build packages and repositories.

## Properties

| Property | Type | Default | Purpose |
| --- | --- | --- | --- |
| `version` | String | `3.13.2.0` | Numeric Snort 3 version |
| `daq_version` | String | `3.0.29` | Numeric DAQ 3 version |
| `prefix` | String | `/opt/snort/<version>` | Exclusively owned versioned installation directory |
| `snort_tar` | String | Upstream version tag archive | Snort source URL |
| `daq_tar` | String | Upstream version tag archive | DAQ source URL |
| `checksum` | String | Pinned default source SHA-256 | Required explicitly for a custom Snort version |
| `daq_checksum` | String | Pinned default DAQ SHA-256 | Required explicitly for a custom DAQ version |
| `enable_build_repositories` | Boolean | `true` | Enable required RHEL developer repositories and EPEL; disable for managed mirrors |
| `build_dependencies` | Array | Platform development packages | Override the package list |
| `build_jobs` | Integer | `2` | Positive number of compiler jobs |

## Example

```ruby
snort_install 'sensor' do
  build_jobs 4
  action :create
end
```

Removal uses an ownership manifest of file hashes, symlink targets and directory names. Creation refuses pre-existing populated directories without a matching manifest. Removal preserves an entire tree if files were added, removed or changed outside this cookbook, or ownership cannot be proved. Inspect and archive such content before removing it manually. An interrupted first installation may require manual recovery; the cookbook does not adopt its partial tree.

Ownership also requires trusted UID/permissions on the tree, receipt and ancestors. Receipts are bound to the canonical path and directory identity; copying a receipt does not adopt another directory.
