module Dpl
  module Providers
    class Scalingo < Provider
      description sq(<<-str)
        tbd
      str

      required :api_key, [:username, :password]

      opt '--api_key KEY', 'scalingo API key', alias: :api_token, deprecated: :api_token
      opt '--username NAME', 'scalingo username'
      opt '--password PASS', 'scalingo password'
      opt '--remote REMOTE', 'Remote url or git remote name of your git repository.', default: 'scalingo'
      opt '--branch BRANCH', 'Branch of your git repository.', default: 'master'
      opt '--app APP', 'Required if your repository does not contain the appropriate remote (will add a remote to your local repository)'

      needs :git, :ssh_key

      cmds login_key:   'timeout 2 ./scalingo login --api-token %{api_key} 2> /dev/null > /dev/null',
           login_creds: 'echo -e \"%{username}\n%{password}\" | timeout 2 ./scalingo login 2> /dev/null > /dev/null',
           add_key:     './scalingo keys-add dpl_tmp_key %s',
           remove_key:  './scalingo keys-remove dpl_tmp_key',
           remote_add:  'git remote add %{remote} git@scalingo.com:%{app}.git 2> /dev/null > /dev/null',
           push:        'git push %{remote} %{branch} -f'

      errs install:    'Failed to install the Scalingo CLI.',
           login:      'Failed to authenticate with the Scalingo API',
           add_key:    'Failed to add the ssh key.',
           push:       'Failed to push the app.',
           remove_key: 'Failed to remove the ssh key.'

      def install
        script :install, assert: true
      end

      def login
        shell api_key ? :login_key : :login_creds, assert: err(:login)
      end

      def add_key(file, type = nil)
        shell :add_key, file, assert: true
      end

      def setup
        shell :remote_add if app
      end

      def deploy
        shell :push, assert: true
      end

      def remove_key
        shell :remove_key, assert: true
      end
    end
  end
end
