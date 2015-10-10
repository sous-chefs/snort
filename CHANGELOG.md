snort Cookbook CHANGELOG
========================
This file is used to list changes made in each version of the snort cookbook.

## v1.0.0:
* Updated to the latest Snort packages on RHEL / Fedora.  For RHEL the minimum supported release is now RHEL 7 due to Snort requirements
* The default package action is now install and not upgrade to prevent service restarts on Chef runs
* Switched to platform_family to support all Debian / RHEL derivitives
* Switch file/dir mode declarations to strings to preserve the leading 0s
* Updated the Contributing doc to reflect the new process
* Added a chef ignore file to prevent unecessary files on the Chef server
* Added a rubocop file and resolved all Rubocop warnings
* Added a Test Kitchen config for testing supported platforms
* Added a Gemfile with development dependencies
* Added a Berksfile for development dependencies

## v0.10.0:

* [COOK-1512] - Update SNORT cookbook with upstream changes for RHEL
  platforms
