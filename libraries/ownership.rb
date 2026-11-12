# frozen_string_literal: true

require 'find'
require 'json'
require 'digest'
require 'tempfile'
require 'fileutils'

module SnortCookbook
  # Refuse to adopt existing content or remove a tree changed outside this cookbook.
  module Ownership
    MARKER = '.chef-snort-owned.json' unless const_defined?(:MARKER)

    def self.snapshot(path)
      result = {}
      Find.find(path) do |entry|
        next if entry == path || entry == "#{path}/#{MARKER}"
        relative = entry.delete_prefix(path + '/')
        stat = File.lstat(entry)
        result[relative] = if stat.symlink?
                             ['link', File.readlink(entry)]
                           elsif stat.directory?
                             ['directory']
                           elsif stat.file?
                             ['file', Digest::SHA256.file(entry).hexdigest]
                           else
                             raise ArgumentError, "Unsupported file in Snort tree: #{entry}"
                           end
        result[relative] += [stat.uid, stat.gid, stat.mode & 0o7777]
      end
      result
    end

    def self.safe_path!(path)
      current = File.expand_path(path)
      loop do
        raise ArgumentError, "Refusing symlink in Snort tree path: #{current}" if File.symlink?(current)
        if File.exist?(current)
          stat = File.stat(current)
          unless [0, Process.uid].include?(stat.uid) && (stat.mode & 0o022).zero?
            raise ArgumentError, "Untrusted owner or writable Snort tree ancestor: #{current}"
          end
        end
        break if current == '/'
        current = File.dirname(current)
      end
    end

    def self.matches?(path)
      safe_path!(path)
      marker = "#{path}/#{MARKER}"
      return false unless File.file?(marker) && !File.symlink?(marker)
      stat = File.stat(marker)
      stat.uid == Process.uid && (stat.mode & 0o077).zero? && JSON.parse(File.read(marker)) == receipt(path)
    rescue JSON::ParserError, ArgumentError, SystemCallError
      false
    end

    def self.prepare!(path)
      safe_path!(path)
      return unless File.exist?(path)
      return if Dir.exist?(path) && (Dir.empty?(path) || matches?(path))
      raise ArgumentError, "Refusing to adopt or overwrite unowned/changed Snort tree: #{path}"
    end

    def self.record!(path)
      safe_path!(path)
      raise ArgumentError, 'Refusing a symlink ownership marker' if File.symlink?("#{path}/#{MARKER}")
      content = JSON.generate(receipt(path))
      Tempfile.create('.chef-snort-', path) do |file|
        file.chmod(0o600)
        file.write(content)
        file.close
        File.rename(file.path, "#{path}/#{MARKER}")
      end
    end

    def self.receipt(path)
      stat = File.stat(path)
      raise ArgumentError, 'Snort tree must belong to the converging user' unless stat.uid == Process.uid
      { 'schema' => 1, 'path' => File.realpath(path), 'identity' => [stat.dev, stat.ino], 'owner' => stat.uid, 'entries' => snapshot(path) }
    end

    def self.promote!(staging, destination)
      raise ArgumentError, 'Unverified staged rules' unless matches?(staging)
      prepare!(destination)
      backup = destination + '.chef-backup'
      raise ArgumentError, "Preserve existing rules backup: #{backup}" if File.exist?(backup) || File.symlink?(backup)
      had_destination = File.exist?(destination)
      File.rename(destination, backup) if had_destination
      begin
        File.rename(staging, destination)
        record!(destination)
      rescue StandardError
        File.rename(destination, staging) if File.exist?(destination)
        File.rename(backup, destination) if had_destination
        raise
      end
      FileUtils.remove_entry_secure(backup) if had_destination
    end
  end
end
