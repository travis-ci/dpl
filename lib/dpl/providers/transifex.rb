module Dpl
  module Providers
    class Transifex < Provider
      description sq(<<-str)
        tbd
      str

      python '>= 2.7', '!= 3.0', '!= 3.1', '!= 3.2', '!= 3.3', '< 3.8'

      required :api_token, [:username, :password]

      opt '--api_token TOKEN', 'Transifex API token'
      opt '--username NAME',   'Transifex username'
      opt '--password PASS',   'Transifex password'
      opt '--hostname NAME',   'Transifex hostname', default: 'www.transifex.com'
      opt '--cli_version VER', 'CLI version to install', default: '>=0.11'

      cmds status: 'tx status',
           push:   'tx push --source --no-interactive'

      msgs login:  'Writing ~/.transifexrc (user: %{username}, password: %{obfuscated_password})'
      errs push:   'Failure pushing to Transifex'

      RC = sq(<<-rc)
        [%{url}]
        hostname = %{url}
        username = %{username}
        password = %{password}
      rc

      def install
        pip_install 'transifex-client', 'tx', cli_version
      end

      def login
        info :login
        write_rc
        shell :status, echo: true
      end

      def deploy
        shell :push, echo: true, retry: true, assert: true
      end

      private

        def write_rc
          write_file '~/.transifexrc', interpolate(RC)
        end

        def username
          super || 'api'
        end

        def password
          super || api_token
        end

        def url
          hostname.start_with?('https://') ? hostname : "https://#{hostname}"
        end
    end
  end
end
