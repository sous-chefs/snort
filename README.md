# snort Cookbook

[![Build Status](https://travis-ci.org/sous-chefs/snort.svg?branch=master)](https://travis-ci.org/sous-chefs/snort) [![Cookbook Version](https://img.shields.io/cookbook/v/snort.svg)](https://supermarket.chef.io/cookbooks/snort)

Installs the SNORT IDS daemon.

## Requirements

### Platforms

- Ubuntu 14.04+
- RHEL/CentOS, 7.0 and higher only.
- Fedora
- Debian 8

### Chef

- Chef 12.1+

## Resources

### Install

- On Ubuntu systems, the packages from apt are used.
- On RHEL and Fedora systems, the packages are retrieved directly from the SNORT project site.
- On Debian the test recipe forces a compiled install.

### Config

Configures `/etc/snort/snort.conf`. We recommend you put your own config in disk using the file resource.

### Rules

Downloads rules for snort.

### Service

Used to setup the `snort_service` for use in other resources.

## Usage

An example usage pattern can be found in the test cookbook.

- Use the `snort_install` to install the package. This also creates the `snort_service` resource which you can use to stop, start & enable the snort service correctly.

RHEL based systems you _must_ use the following resources (optional on Debian based systems).

- Use `snort_config` to configure the system.
- Use `snort_rules` to install rules. You will need a licence for this.

Example configs can be found in `test/fixtures/cookbooks/test/`

## References

- [SNORT home page](http://www.snort.org)

## License

- Copyright 2017, Webb Agile Solutions Ltd.
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
