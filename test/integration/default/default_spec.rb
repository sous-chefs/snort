describe file('/usr/sbin/snort') do
  it { should exist }
end

if os[:family] == 'redhat' || os[:family] == 'fedora'
  describe service('snortd') do
    it { should be_enabled }
    it { should be_running }
  end
else
  describe service('snort') do
    it { should be_enabled }
    it { should be_running }
  end
end
