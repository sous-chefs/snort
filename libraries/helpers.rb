module SnortCookbook
  module Helpers
    def system_lib_dir
      if node['kernel']['machine'] == 'x86_64'
        '/lib64'
      else
        '/lib'
      end
    end

    def package_suffix
      if platform?('fedora')
        '.f29'
      else
        '.centos7'
      end
    end

    def snort_package
      case new_resource.database
      when 'none'
        'snort'
      when 'mysql'
        'snort-mysql'
      when 'postgresql', 'pgsql', 'postgres'
        'snort-pgsql'
      end
    end

    def default_interface
      require 'mixlib/shellout'

      default_interface = Mixlib::ShellOut.new("route | grep default | awk '{print $8}'")
      default_interface.run_command.stdout.strip!
    end
  end
end
