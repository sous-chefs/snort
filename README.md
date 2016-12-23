# snort Cookbook

[![Build Status](https://travis-ci.org/sous-chefs/snort.svg?branch=master)](https://travis-ci.org/sous-chefs/snort) [![Cookbook Version](https://img.shields.io/cookbook/v/snort.svg)](https://supermarket.chef.io/cookbooks/snort)

Installs the SNORT IDS daemon. On Debian/Ubuntu systems, the packages from apt are used. On RHEL and Fedora systems, the packages are retrieved directly from the SNORT project site.

## Requirements

### Platforms

- Ubuntu 12.04+
- RHEL/CentOS, 7.0 and higher only.
- Fedora

### Chef

- Chef 12.1+

### Cookbooks

- compat_resource to bring custom_resource functionality to chef-client < 12.5

## Attributes

See `attributes/default.rb` for default values.

- `node['snort']['home_net']` - Address range to use for preseeding `HOME_NET`.
- `node['snort']['database']` - The database backend to use. Only applicable on Debian/Ubuntu systems. Default none. MySQL and PostgreSQL are usable. The default recipe will install the SNORT package for the appropriate database backend. You'll need to make sure that the database server is set up in some way such that SNORT can connect to it. This cookbook does not yet support automatic configuration.
- `node['snort']['rpm']['daq_version']` - The full version string of the daq package to install, e.g. "`2.0.0-1.fc17`".
- `node['snort']['rpm']['daq_checksum']` - The SHA256 checksum of the daq rpm.
- `node['snort']['rpm']['version']` - The full version string of the snort package to install, e.g., "`2.9.4-1.f17`".
- `node['snort']['rpm']['checksum']` - The SHA256 checksum of the snort rpm.

## Recipes

### default.rb

Includes the _install.rb and _service.rb recipes

### _install.rb

Installs the snort package from apt on Debian based systems, or RPMs downloaded from the snort.org site on RHEL based systems

### _service.rb

Used the snort_service custom resource to start and enable the snort service

## Resources

### snort_service

#### Properties

- service_name: To override the platform based service_name used to start/enable the service pass a string here

#### Examples

```
snort_service 'snort' do
  action :start
end
```

```
snort_service 'snort' do
  action [:start, :enable]
end
```

## Usage

Include `recipe[snort]` in a run list to have the system get SNORT installed and the service started. This performs a baseline installation and preseeds the package. You should change the `node['snort']['home_net']` attribute to the appropriate network.

We recommend adding a `template` resource to the default recipe to manage the `/etc/snort/snort.conf` file as a template. The default file is good enough for now on Debian/Ubuntu.

On Ubuntu/Debian, the default rules package will be installed. You'll need to download and install additional rules. Automatically updating rules with oinkmaster is not yet supported. See future plans.

## Future Plans

The following features are planned for a future release of this cookbook. Contributions welcome.

- Service management
- Config management
- Additional platforms

## References

- [SNORT home page](http://www.snort.org)
- [SNORT database output is dead](http://blog.snort.org/2012/07/database-output-is-dead-rip.html)

## License & Authors

- Author: Joshua Timberman ([joshua@chef.io](mailto:joshua@chef.io))
- Author: Tim Smith ([tsmith@chef.io](mailto:tsmith@chef.io))
- Copyright 2015-2016, Cozy Services Ltd.
- Copyright 2010-2016, Chef Software, Inc.

```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
