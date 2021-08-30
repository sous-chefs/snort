# snort Cookbook CHANGELOG

This file is used to list changes made in each version of the snort cookbook.

## Unreleased

- Standardise files with files in sous-chefs/repo-management

## 5.0.1 (2021-06-01)

- Standardise files with files in sous-chefs/repo-management

## 5.0.0 (2020-05-05)

- Migrate to Github Actions
- Replace zip extraction with archive_file *Breaking change*

## v4.0.2 (2019-06-25)

- Added CircleCI 2.0 support

## v4.0.1 (2018-12-14)

- Updated checksums for the snort package on CentOS and Fedora

## v4.0.0 (2018-08-28)

- Drop Chef-12 support

## v3.0.1 (2018-08-28)

- Fix service start bug on RHEL platforms
- Move resource helpers to a shared helpes file

## v3.0.0 (2017-05-03)

- New custom resources for `snort_install`, `snort_compile`, `snort_rules`, `snort_config`
- Updated `snort_service`

## v2.1.0

- Update the versions to the latest snort on RHEL/Fedora
- Require at least compat_resource 12.9 to prevent random issues
- Remove Chef 11 compatibility from the metadata file
- Use kitchen-dokken in Travis CI

## v2.0.0

- Added new snort_service custom resource and a _service.rb recipe. The recipe is called by the default.rb recipe. The custom resource can be used to write wrapper cookbooks and supports the standard service actions (enable, start, restart, reload). The custom resource used the new Chef 12.5 customer resource format and the compat_resource cookbook for compatibility with 12.0+

## v1.1.0

- Updated to the latest daq and snort packages for RHEL
- Added Chefspecs for RHEL/Debian platforms
- Moved all install logic into _install.rb recipe which is called by the default recipe. This changes nothing, but prepares things for adding more functionality at a later date.
- Updated platforms in the Kitchen CI config
- Added source_url and issues_url metadata for Supermarket
- Updated Travis config to test via ChefDK and to use kitchen-docker for integration tests
- Removed yum cookbook from the Berksfile since it wasn't needed
- Removed the Contributing doc since it was from when this cookbook was managed by Chef Software Inc.
- Added standard Chef development gems to the Gemfile
- Removed references to database output from the Readme
- Added a Rakefile for simplified testing

## v1.0.0

- Updated to the latest Snort packages on RHEL / Fedora. For RHEL the minimum supported release is now RHEL 7 due to Snort requirements
- The default package action is now install and not upgrade to prevent service restarts on Chef runs
- Switched to platform_family to support all Debian / RHEL derivitives
- Switch file/dir mode declarations to strings to preserve the leading 0s
- Updated the Contributing doc to reflect the new process
- Added a chef ignore file to prevent unecessary files on the Chef server
- Added a rubocop file and resolved all Rubocop warnings
- Added a Test Kitchen config for testing supported platforms
- Added a Gemfile with development dependencies
- Added a Berksfile for development dependencies

## v0.10.0

- [COOK-1512] - Update SNORT cookbook with upstream changes for RHEL platforms
