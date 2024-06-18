# frozen_string_literal: true

module Dpl
  module Providers
    class Transifex < Provider
      register :transifex

      status :alpha

      description sq(<<-STR)
        tbd
      STR

      python '>= 2.7', '!= 3.0', '!= 3.1', '!= 3.2', '!= 3.3', '< 3.12'

      required :api_token, %i[username password]

      env :transifex

      opt '--api_token TOKEN', 'Transifex API token', secret: true
      opt '--username NAME',   'Transifex username'
      opt '--password PASS',   'Transifex password', secret: true
      opt '--hostname NAME',   'Transifex hostname', default: 'www.transifex.com'
      opt '--cli_version VER', 'CLI version to install', default: '>=0.11'

      cmds status: 'tx status',
           push: 'tx push --source --no-interactive'

      msgs login:  'Writing ~/.transifexrc (user: %{username}, password: %{password})'
      errs push:   'Failure pushing to Transifex'

      RC = sq(<<-RC)
        [%{url}]
        hostname = %{url}
        username = %{username}
        password = %{password}
      RC

      def install
        pip_install 'transifex-client', 'tx', cli_version
      end

      def login
        info :login
        write_rc
        shell :status
      end

      def deploy
        shell :push, retry: true
      end

      private

      def write_rc
        write_file '~/.transifexrc', interpolate(RC, opts, secure: true)
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
