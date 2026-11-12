# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'
require_relative '../../libraries/ownership'

describe SnortCookbook::Ownership do
  around do |example|
    Dir.mktmpdir('snort-ownership', Dir.home) do |path|
      @path = File.realpath(path)
      example.run
    end
  end

  it 'refuses to adopt a pre-existing populated directory' do
    File.write("#{@path}/sentinel", 'keep')
    expect { described_class.prepare!(@path) }.to raise_error(ArgumentError, /unowned/)
  end

  it 'recognises only an unchanged recorded tree' do
    File.write("#{@path}/managed", 'installed')
    described_class.record!(@path)
    expect(described_class.matches?(@path)).to be true
    File.write("#{@path}/later", 'keep')
    expect(described_class.matches?(@path)).to be false
    expect { described_class.prepare!(@path) }.to raise_error(ArgumentError, /changed/)
  end

  it 'preserves evidence of modified files and symlink targets' do
    File.write("#{@path}/managed", 'installed')
    File.symlink('managed', "#{@path}/link")
    described_class.record!(@path)
    File.write("#{@path}/managed", 'edited')
    expect(described_class.matches?(@path)).to be false
  end

  it 'rejects a symlink in any parent directory' do
    File.symlink(@path, "#{@path}/link")
    expect { described_class.prepare!("#{@path}/link/child") }.to raise_error(ArgumentError, /symlink/)
  end

  it 'does not trust a receipt copied to an identical different directory' do
    File.write("#{@path}/managed", 'installed')
    described_class.record!(@path)
    Dir.mktmpdir('snort-copy', Dir.home) do |copy|
      FileUtils.cp_r(Dir.glob("#{@path}/*", File::FNM_DOTMATCH).reject { |entry| %w(. ..).include?(File.basename(entry)) }, copy)
      expect(described_class.matches?(File.realpath(copy))).to be false
    end
  end

  it 'does not trust a writable receipt' do
    described_class.record!(@path)
    File.chmod(0o666, "#{@path}/#{described_class::MARKER}")
    expect(described_class.matches?(@path)).to be false
  end

  it 'does not trust a writable root directory' do
    described_class.record!(@path)
    File.chmod(0o777, @path)
    expect(described_class.matches?(@path)).to be false
  end

  it 'refuses a writable ancestor' do
    File.chmod(0o777, @path)
    expect { described_class.prepare!("#{@path}/new") }.to raise_error(ArgumentError, /ancestor/)
  end

  it 'does not follow a marker symlink when recording ownership' do
    File.write("#{@path}/sentinel", 'keep')
    File.symlink("#{@path}/sentinel", "#{@path}/#{described_class::MARKER}")
    expect { described_class.record!(@path) }.to raise_error(ArgumentError, /symlink/)
    expect(File.read("#{@path}/sentinel")).to eq('keep')
  end

  context 'rule promotion' do
    before do
      @destination = "#{@path}/rules"
      @staging = "#{@path}/stage"
      Dir.mkdir(@destination)
      Dir.mkdir(@staging)
      File.write("#{@destination}/old.rules", 'old')
      File.write("#{@staging}/new.rules", 'new')
      described_class.record!(@destination)
      described_class.record!(@staging)
    end

    it 'promotes a verified replacement and binds its receipt to the final path' do
      described_class.promote!(@staging, @destination)
      expect(described_class.matches?(@destination)).to be true
      expect(File.read("#{@destination}/new.rules")).to eq('new')
      expect(File.exist?("#{@destination}/old.rules")).to be false
      expect(File.exist?(@staging)).to be false
      expect(File.exist?(@destination + '.chef-backup')).to be false
    end

    it 'preserves the installed rules if the staged tree is not verified' do
      File.write("#{@staging}/unexpected", 'operator')
      expect { described_class.promote!(@staging, @destination) }.to raise_error(ArgumentError, /Unverified/)
      expect(File.read("#{@destination}/old.rules")).to eq('old')
    end

    it 'rolls back both trees if binding the promoted receipt fails' do
      allow(described_class).to receive(:record!).with(@destination).and_raise(IOError, 'receipt failure')
      expect { described_class.promote!(@staging, @destination) }.to raise_error(IOError, /receipt failure/)
      expect(described_class.matches?(@destination)).to be true
      expect(described_class.matches?(@staging)).to be true
      expect(File.read("#{@destination}/old.rules")).to eq('old')
    end
  end
end
