module Dpl
  module Providers
    class Scalingo < Provider
      description sq(<<-str)
        tbd
      str

      required :api_key, [:username, :password]

      opt '--app APP', default: :repo_name
      opt '--api_key KEY', 'scalingo API key', alias: :api_token, deprecated: :api_token
      opt '--username NAME', 'scalingo username'
      opt '--password PASS', 'scalingo password'
      opt '--remote REMOTE', 'Git remote name', default: 'scalingo'
      opt '--branch BRANCH', 'Git branch', default: 'master'

      needs :git, :ssh_key

      cmds login_key:   'timeout 2 ./scalingo login --api-token %{api_key} > /dev/null 2>&1',
           login_creds: 'echo -e \"%{username}\n%{password}\" | timeout 2 ./scalingo login > /dev/null 2>&1',
           add_key:     './scalingo keys-add dpl_tmp_key %{key}',
           remove_key:  './scalingo keys-remove dpl_tmp_key',
           remote_add:  'git remote add %{remote} git@scalingo.com:%{app}.git > /dev/null 2>&1',
           push:        'git push %{remote} HEAD:%{branch} -f'

      errs install:    'Failed to install the Scalingo CLI.',
           login:      'Failed to authenticate with the Scalingo API.',
           add_key:    'Failed to add the ssh key.',
           remote_add: 'Failed to add the git remote.',
           push:       'Failed to push the app.',
           remove_key: 'Failed to remove the ssh key.'

      def install
        script :install, assert: true, echo: true
      end

      def login
        puts `ls -al ~/.dpl`
        p api_key?
        shell api_key ? :login_key : :login_creds, assert: err(:login)
      rescue => e
        p e
      end

      def add_key(key, type = nil)
        shell :add_key, key: key, assert: true, echo: true
      end

      def setup
        shell :remote_add, assert: true, echo: true
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
