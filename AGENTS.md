# Snort 3 migration

The owner explicitly chose a full custom resource migration and Snort 3. Ship a
breaking feature to main before regenerating release #106 as cookbook 6.0.0.
Keep the current shared CI pins (9.0.1), not obsolete skill examples.

## Vendor findings

* Current Snort is 3.13.2.0, released 5 November 2026; DAQ 3.0.29 is required.
* C++17, CMake, LuaJIT, PCRE2, libpcap, libdnet, hwloc, OpenSSL and zlib are
  required. LibML and Hyperscan are optional; the portable default omits LibML.
* The old cookbook installs Snort 2 packages. The new default compiles pinned
  upstream sources into an exclusively owned versioned prefix.
* RHEL 8/9 and Ubuntu 22.04 ship older zlib versions. Build pinned zlib 1.4
  privately, not over the system library. Amazon Linux 2023 lacks libdnet-devel,
  so build vendor-linked libdnet 1.18.2 privately as well.
* Preserve non-EOL Debian, Ubuntu, RHEL-compatible, Fedora, Oracle and Amazon
  releases; remove EOL Scientific Linux, CentOS Linux and Amazon Linux 2.
* Snort 2 configuration, database outputs and shared-object rules are not
  compatible. Keep install/compile/config/rules/service resource names and
  document changed properties instead of pretending configuration is portable.
* Installation does not capture traffic automatically. Service creation and
  interface selection are explicit. Tests capture only isolated container lo.
* Never use the Parallels lab for this task; VM work is paused by the owner.

Sources: <https://github.com/snort3/snort3>,
<https://github.com/snort3/libdaq>, <https://snort.org/snort3>,
<https://docs.snort.org/start/installation>.

## Implementation and acceptance

* Linux x86_64 is the hosted CI target; local aarch64 Ubuntu 24.04 converged
  idempotently (0/36 updates) and passed 10 integration assertions, including
  actual synthetic-PCAP detection. Reverify current head before publication.
* Upstream sets CMAKE_SKIP_RPATH=ON. Pass an explicit executable linker rpath
  for the private DAQ and dnet libraries rather than changing the system loader.
* Build under /var/cache/snort3, not the Kitchen shared sandbox: autoreconf
  failed on the macOS shared filesystem and passed on the container filesystem.
* Snort rule include statements need a final newline. Verify Lua configuration
  before replacing it and test the last included rule with an actual PCAP.
* RHEL derivatives need EPEL and CRB/PowerTools/CodeReady Builder. Native RHEL
  uses its existing RHSM subscription; the cookbook does not register one.
  Set enable_build_repositories false when an organisation manages mirrors.
* All 18 declared Dokken image tags were confirmed available. Keep every
  Kitchen platform list and the CI matrix aligned; no obsolete exec/VM configs.
* EOL baselines were checked using <https://endoflife.date/api/>: Debian 11 ended
  August 2026, Amazon Linux 2 June 2026; retain Debian 12/13, Ubuntu 22/24/26 LTS,
  RHEL-compatible 8/9/10, CentOS Stream 9/10, Amazon Linux 2023 and current Fedora.

* The vendor base policy initialises eight protected server network variables
  from its initial HOME_NET. Reset those aliases when applying home_net in the
  wrapper. Positive and negative PCAP controls verify the actual rule scope.

Review findings: never recursively remove unowned or subsequently changed trees. Ownership snapshots guard prefix, source cache and rule extraction; logs are retained when non-empty. Debian 13 and Ubuntu 26.04 images require /usr/lib/systemd/systemd rather than the removed /bin/systemd alias.

Ownership receipts require the converging UID, private marker permissions, trusted non-writable ancestors and the exact canonical path/device/inode. Atomic receipt writes refuse marker symlinks. Rules extract and validate in a new staging tree before promotion; receipt rebinding failures roll back the previous tree. Interrupted unowned staging trees require manual inspection, never automatic adoption.

Snort 3.13.2.0 marks appid_log inline only in appid_debug.cc despite external callers. GCC 16 omits its symbol and Fedora fails to link. Remove that qualifier only for this exact version and the verified file SHA-256 b7510d4d5ecdbd848f7342d78e7d35a13dddc824edbe89a77edd0e2252626fea; do not patch unrelated versions. The build signature includes this correction, OS version and explicit dependency list. See <https://github.com/snort3/snort3/blob/3.13.2.0/src/network_inspectors/appid/appid_debug.cc> and <https://gcc.gnu.org/onlinedocs/gcc/Inline.html>.

Systemd expands dollar variables even inside quotes. Encode literal dollars as double dollars, double percent specifiers and backslashes, escape quotes and standalone semicolons, and reject control characters. See <https://github.com/systemd/systemd/blob/main/man/systemd.service.xml>.
