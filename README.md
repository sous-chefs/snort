Description
===========

Installs and configures SNORT. On Debian/Ubuntu systems, the packages
from apt are used. On RHEL and Fedora systems, the packages are
retrieved directly from the SNORT project site.

Requirements
============

## Platform

* Ubuntu 10.04, 12.04
* RHEL/CentOS, 6.0 and higher only.
* Fedora 17

May work on other platforms in the Debian and RHEL families with or
without modification.

## Cookbooks

No other cookbooks are dependencies, however to use one of the
database backends, the appropriate cookbook should be used. For
example, Opscode cookbooks:

* mysql
* postgresql

Attributes
==========

See `attributes/default.rb` for default values.

* `node['snort']['home_net']` - Address range to use for preseeding
  `HOME_NET`.
* `node['snort']['database']` - The database backend to use. Only
  applicable on Debian/Ubuntu systems. Default none. MySQL and
  PostgreSQL are usable. The default recipe will install the SNORT
  package for the appropriate database backend. You'll need to make
  sure that the database server is set up in some way such that SNORT
  can connect to it. This cookbook does not yet support automatic
  configuration.
* `node['snort']['rpm']['daq_version']` - The full version string of
  the daq package to install, e.g. "`2.0.0-1.fc17`".
* `node['snort']['rpm']['daq_checksum']` - The SHA256 checksum of the
  daq rpm.
* `node['snort']['rpm']['version']` - The full version string of the
  snort package to install, e.g., "`2.9.4-1.f17`".
* `node['snort']['rpm']['checksum']` - The SHA256 checksum of the
  snort rpm.

**NOTE** Upstream, the SNORT project has deprecated the database
  output
  [as of version 2.9.3](http://blog.snort.org/2012/07/database-output-is-dead-rip.html).

Usage
=====

Include `recipe[snort]` in a run list to have the system get SNORT
installed. This performs a baseline installation and preseeds the
package. You should change the `node['snort']['home_net']` attribute
to the appropriate network.

We recommend adding a `template` resource to the default recipe to
manage the `/etc/snort/snort.conf` file as a template. The default
file is good enough for now on Debian/Ubuntu.

On Ubuntu/Debian, the default rules package will be installed. You'll
need to download and install additional rules. Automatically updating
rules with oinkmaster is not yet supported. See future plans.

Future Plans
============

The following features are planned for a future release of this
cookbook. Contributions welcome, see
[How to Contribute](http://wiki.opscode.com/display/chef/How+to+Contribute)

Perform additional configuration of `/etc/snort/snort.conf` via
template.

Oinkmaster automatic rules updates.

Source-based installation.

Other platforms in general :).

References
==========

* [SNORT home page](http://www.snort.org)
* [snort -h doesn't do what you think](http://blog.joelesler.net/2010/03/snort-h-doesnt-do-what-you-think-it-does.html)
* [SNORT database output is dead](http://blog.snort.org/2012/07/database-output-is-dead-rip.html)

License and Author
==================

- Author: Joshua Timberman (<joshua@opscode.com>)
- Copyright 2010-2012, Opscode, Inc (<legal@opscode.com>)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
