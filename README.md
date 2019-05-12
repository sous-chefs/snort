# snort Cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/snort.svg)](https://supermarket.chef.io/cookbooks/snort)
[![Build Status](https://img.shields.io/circleci/project/github/sous-chefs/snort/master.svg)](https://circleci.com/gh/sous-chefs/snort)
[![OpenCollective](https://opencollective.com/sous-chefs/backers/badge.svg)](#backers)
[![OpenCollective](https://opencollective.com/sous-chefs/sponsors/badge.svg)](#sponsors)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://opensource.org/licenses/Apache-2.0)

Installs the SNORT IDS daemon.

## Maintainers

This cookbook is maintained by the Sous Chefs. The Sous Chefs are a community of Chef cookbook maintainers working together to maintain important cookbooks. If you’d like to know more please visit [sous-chefs.org](https://sous-chefs.org/) or come chat with us on the Chef Community Slack in [#sous-chefs](https://chefcommunity.slack.com/messages/C2V7B88SF).

## Requirements

### Platforms

- Ubuntu 14.04+
- RHEL/CentOS, 7.0 and higher only.
- Fedora
- Debian 8+

### Chef

- Chef 12.7+

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

## Contributors

This project exists thanks to all the people who [contribute.](https://opencollective.com/sous-chefs/contributors.svg?width=890&button=false)

### Backers

Thank you to all our backers!

![https://opencollective.com/sous-chefs#backers](https://opencollective.com/sous-chefs/backers.svg?width=600&avatarHeight=40)

### Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website.

![https://opencollective.com/sous-chefs/sponsor/0/website](https://opencollective.com/sous-chefs/sponsor/0/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/1/website](https://opencollective.com/sous-chefs/sponsor/1/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/2/website](https://opencollective.com/sous-chefs/sponsor/2/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/3/website](https://opencollective.com/sous-chefs/sponsor/3/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/4/website](https://opencollective.com/sous-chefs/sponsor/4/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/5/website](https://opencollective.com/sous-chefs/sponsor/5/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/6/website](https://opencollective.com/sous-chefs/sponsor/6/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/7/website](https://opencollective.com/sous-chefs/sponsor/7/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/8/website](https://opencollective.com/sous-chefs/sponsor/8/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/9/website](https://opencollective.com/sous-chefs/sponsor/9/avatar.svg?avatarHeight=100)
