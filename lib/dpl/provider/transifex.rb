module DPL
  class Provider
    class Transifex < Provider
      experimental 'Transifex'

      DEFAULT_HOSTNAME = 'https://www.transifex.com'

      def install_deploy_dependencies
        if options[:cli_version]
          self.class.pip 'transifex-client', 'tx', cli_version
        else
          self.class.pip 'transifex-client', 'tx'
        end
      end

      def needs_key?
        false
      end

      def check_auth
        install_deploy_dependencies
        write_transifexrc
        context.shell 'tx status'
      end

      def push_app
        source_push
      end

      def write_transifexrc
        File.open(File.expand_path('~/.transifexrc'), 'w') do |f|
          f.puts [
            "[#{options[:hostname] || DEFAULT_HOSTNAME}]",
            "hostname = #{options[:hostname] || DEFAULT_HOSTNAME}",
            "username = #{options[:username]}",
            "password = #{options[:password]}",
            "token = #{options[:token]}",
          ].join("\n")
        end
      end

      def source_push
        context.shell 'tx push --source --no-interactive', retry: true
      end
    end
  end
end
