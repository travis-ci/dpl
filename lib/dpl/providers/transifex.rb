module Dpl
  module Providers
    class Transifex < Provider
      description sq(<<-str)
        tbd
      str

      # Make sure we have the Python version needed. Maybe add a python DSL
      # that installs the needed version if not available?

      required :api_token, [:username, :password]

      opt '--api_token TOKEN', 'Transifex API token'
      opt '--username NAME',   'Transifex username'
      opt '--password PASS',   'Transifex password'
      opt '--hostname NAME',   'Transifex hostname', default: 'www.transifex.com'
      # this used to be 0.11, but that version does not seem to exist in pip.
      # should check this with transifex though
      opt '--cli_version VER', 'CLI version to install', default: '>=0.11'

      cmds status: 'tx status',
           push:   'tx push --source --no-interactive'

      msgs rc:   'Writing ~/.transifexrc (user: %{username}, password: %{obfuscated_password})'
      errs push: 'Failure pushing to Transifex'

      def install
        pip_install 'transifex-client', 'tx', cli_version
      end

      def login
        write_rc
        shell :status
      end

      def deploy
        shell :push, retry: true, assert: true
      end

      private

        def username
          super || 'api'
        end

        def password
          super || api_token
        end

        RC = sq(<<-rc)
          [%{url}]
          hostname = %{url}
          username = %{username}
          password = %{password}
        rc

        def write_rc
          info :rc
          write_file('~/.transifexrc', interpolate(RC))
        end

        def url
          hostname.start_with?('https://') ? hostname : "https://#{hostname}"
        end
    end
  end
end
