module Dpl
  module Providers
    class Transifex < Provider
      summary 'Transifex deployment provider'

      description <<~str
        tbd
      str

      experimental 'Transifex'

      opt '--username NAME',   'Transifex username', required: true
      opt '--password PASS',   'Transifex password', required: true
      opt '--hostname NAME',   'Transifex hostname', default: 'www.transifex.com'
      opt '--cli_version VER', 'CLI version to install', default: '>=0.11'

      CMDS = {
        status: 'tx status',
        push:   'tx push --source --no-interactive'
      }

      def install
        pip 'transifex', 'transifex', cli_version
      end

      def setup
        write_rc
      end

      def login
        shell :status
      end

      def deploy
        shell :push, retry: true
      end

      private

        def write_rc
          File.open(rc_path, 'w') { |f| f.write(rc) }
        end

        RC = <<~rc
          [%{hostname}]
          hostname = %{hostname}
          username = %{username}
          password = %{password}
        rc

        def rc
          RC % { hostname: url, username: username, password: password }
        end

        def rc_path
          File.expand_path('~/.transifexrc')
        end

        def url
          hostname.start_with?('https://') ? hostname : "https://#{hostname}"
        end
    end
  end
end
