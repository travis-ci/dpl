module Dpl
  module Providers
    class Scalingo < Provider
      description sq(<<-str)
        tbd
      str

      required :api_key, [:username, :password]

      opt '--app APP', default: :repo_name
      opt '--api_key KEY', 'Scalingo API key', alias: :api_token, deprecated: :api_token
      opt '--username NAME', 'Scalingo username'
      opt '--password PASS', 'Scalingo password'
      opt '--region REGION', 'Scalingo region', default: 'agora-fr1', enum: %w(agora-fr1 osc-fr1)
      opt '--remote REMOTE', 'Git remote name', default: 'scalingo-dpl'
      opt '--branch BRANCH', 'Git branch', default: 'master'
      opt '--timeout SEC', 'Timeout for Scalingo CLI commands', default: 60

      needs :git, :ssh_key

      cmds login_key:   'timeout %{timeout} ./scalingo login --api-token %{api_key} > /dev/null 2>&1',
           login_creds: 'echo -e \"%{username}\n%{password}\" | timeout %{timeout} ./scalingo login > /dev/null 2>&1',
           add_key:     'timeout %{timeout} ./scalingo keys-add dpl_tmp_key %{key}',
           remove_key:  'timeout %{timeout} ./scalingo keys-remove dpl_tmp_key',
           git_setup:   './scalingo --app %{app} git-setup --remote %{remote}',
           push:        'git push %{remote} HEAD:%{branch} -f'

      errs install:    'Failed to install the Scalingo CLI.',
           login:      'Failed to authenticate with the Scalingo API.',
           add_key:    'Failed to add the ssh key.',
           remove_key: 'Failed to remove the ssh key.',
           git_setup:  'Failed to add the git remote.',
           push:       'Failed to push the app.'

      def install
        script :install, assert: true
        ENV['SCALINGO_REGION'] = region if region?
      end

      def login
        shell api_key ? :login_key : :login_creds, assert: err(:login)
      end

      def add_key(key, type = nil)
        shell :add_key, key: key, assert: true, echo: true
      end

      def setup
        shell :git_setup, assert: true, echo: true
      end

      def deploy
        shell :push, assert: true, echo: true
      end

      def remove_key
        shell :remove_key, assert: true, echo: true
      end
    end
  end
end
