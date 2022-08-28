module Dpl
  module Providers
    class Scalingo < Provider
      register :scalingo

      status :alpha

      description sq(<<-str)
        tbd
      str

      env :scalingo

      required :api_token, [:username, :password]

      opt '--app APP', default: :repo_name
      opt '--api_token TOKEN', 'Scalingo API token', alias: :api_key, deprecated: :api_key
      opt '--username NAME', 'Scalingo username'
      opt '--password PASS', 'Scalingo password', secret: true
      opt '--region REGION', 'Scalingo region', default: 'osc-fr1'
      opt '--remote REMOTE', 'Git remote name', default: 'scalingo-dpl'
      opt '--timeout SEC', 'Timeout for Scalingo CLI commands', default: 60, type: :integer
      opt '--deploy-method METHOD', 'Method of deployment, git or archive', default: 'git'

      needs :git, :ssh_key

      cmds login_key:      'timeout %{timeout} ./scalingo login --api-token %{api_token} > /dev/null',
           login_creds:    'echo -e \"%{username}\n%{password}\" | timeout %{timeout} ./scalingo login > /dev/null',
           add_key:        'timeout %{timeout} ./scalingo keys-add dpl_tmp_key %{key}',
           remove_key:     'timeout %{timeout} ./scalingo keys-remove dpl_tmp_key',
           git_setup:      './scalingo --app %{app} git-setup --remote %{remote}',
           fetch:          'git fetch origin --unshallow',
           push:           'git push %{remote} HEAD:refs/heads/master -f',
           archive:        'git archive --prefix dpl-scalingo-deploy/ HEAD | gzip - > dpl-scalingo-deploy.tar.gz',
           archive_deploy: './scalingo --app %{app} deploy "dpl-scalingo-deploy.tar.gz" "%{ref}"'

      errs install:        'Failed to install the Scalingo CLI.',
           login:          'Failed to authenticate with the Scalingo API.',
           add_key:        'Failed to add the ssh key.',
           remove_key:     'Failed to remove the ssh key.',
           git_setup:      'Failed to add the git remote.',
           push:           'Failed to push the app.',
           archive:        'Failed to create code archive',
           archive_deploy: 'Failed to deploy the code archive'

      def install
        script :install
        ENV['SCALINGO_REGION'] = region if region?
      end

      def login
        shell api_token ? :login_key : :login_creds, assert: err(:login)
      end

      def add_key(key, type = nil)
        return if deploy_method == 'archive'

        shell :add_key, key: key
      end

      def setup
        return if deploy_method == 'archive'

        shell :git_setup
      end

      def deploy
        if deploy_method == 'git'
          # pushing code from a shallow repository is not possible with git,
          # the :fetch action aims at transforming a shallow clone of the
          # repository usually used by CIs to a complete git repository
          #
          # If the repository is already full, the command will return an error
          # we will ignore (assert: false)
          shell :fetch, assert: false
          shell :push
        elsif deploy_method == 'archive'
          shell :archive
          shell :archive_deploy, ref: archive_ref
        end
      end

      def remove_key
        return if deploy_method == 'archive'

        shell :remove_key
      end

      private

      def archive_ref
        # Compatibility with Gitlab CI and Travis CI
        ENV['CI_COMMIT_SHA'] || ENV['TRAVIS_COMMIT'] || "dpl-#{Time.now.to_i.to_s}"
      end
    end
  end
end
