module Dpl
  module Providers
    class Pages
      class Git < Pages
        register :'pages:git'

        status :stable

        full_name 'GitHub Pages'

        description sq(<<-str)
          tbd
        str

        gem 'octokit', '~> 4.15.0'
        gem 'public_suffix', '~> 3.0.3'

        required :token, :deploy_key

        opt '--repo SLUG', 'Repo slug', default: :repo_slug
        opt '--token TOKEN', 'GitHub token with repo permission', secret: true, alias: :github_token
        opt '--deploy_key PATH', 'Path to a file containing a private deploy key with write access to the repository', see: 'https://developer.github.com/v3/guides/managing-deploy-keys/#deploy-keys'
        opt '--target_branch BRANCH', 'Branch to push force to', default: 'gh-pages'
        opt '--keep_history', 'Create incremental commit instead of doing push force', default: true
        opt '--commit_message MSG', default: 'Deploy %{project_name} to %{url}:%{target_branch}', interpolate: true
        opt '--allow_empty_commit', 'Allow an empty commit to be created', requires: :keep_history
        opt '--verbose', 'Be verbose about the deploy process'
        opt '--local_dir DIR', 'Directory to push to GitHub Pages', default: '.'
        opt '--target_dir DIR', 'Target directory within repository', default: '.'
        opt '--fqdn FQDN', 'Write the given domain name to the CNAME file'
        opt '--project_name NAME', 'Used in the commit message only (defaults to fqdn or the current repo slug)'
        opt '--name NAME', 'Committer name', note: 'defaults to the current git commit author name'
        opt '--email EMAIL', 'Committer email', note: 'defaults to the current git commit author email'
        opt '--committer_from_gh', 'Use the token\'s owner name and email for the commit', requires: :token
        opt '--deployment_file', 'Enable creation of a deployment-info file'
        opt '--url URL', default: 'github.com', alias: :github_url

        needs :git

        msgs login:               'Authenticated as %s',
             invalid_token:       'The provided GitHub token is invalid (error: %s)',
             insufficient_scopes: 'Dpl does not have permission to access %{url} using the provided GitHub token. Please make sure the token have the repo or public_repo scope.',
             setup_deploy_key:    'Moving deploy key %{deploy_key} to %{path}',
             check_deploy_key:    'Checking deploy key',
             deploy:              'Deploying branch %{target_branch} to %{url}',
             keep_history:        'The deployment is configured to preserve the target branch if it exists on remote.',
             work_dir:            'Using temporary work directory %{work_dir}',
             committer_from_gh:   'The repo is configured to use committer user and email.',
             setup_dir:           'The source dir for deployment is %s',
             target_dir:          'The target dir for deployment is %s',
             git_clone:           'Cloning the branch %{target_branch} from the remote repo',
             git_init:            'Initializing local git repo',
             git_checkout:        'Checking out orphan branch %{target_branch}',
             copy_files:          'Copying %{src_dir} contents to %{dst_dir}',
             git_config:          'Configuring git committer to be %{name} <%{email}>',
             prepare:             'Preparing to deploy %{target_branch} branch to gh-pages',
             git_push:            'Pushing to %{url}',
             stop:                'There are no changes to commit, stopping.'

        cmds git_clone:           'git clone --quiet --branch="%{target_branch}" --depth=1 "%{remote_url}" . > /dev/null 2>&1',
             git_init:            'git init .',
             git_checkout:        'git checkout --orphan "%{target_branch}"',
             check_deploy_key:    'ssh -i %{key} -T git@github.com 2>&1 | grep successful > /dev/null',
             copy_files:          'rsync -rl --exclude .git --delete "%{src_dir}/" "%{dst_dir}"',
             git_config_email:    'git config user.email %{quoted_email}',
             git_config_name:     'git config user.name %{quoted_name}',
             deployment_file:     'touch "deployed at %{now} by %{name}"',
             cname:               'echo "%{fqdn}" > CNAME',
             git_add:             'git add -A .',
             git_commit_hook:     'cp %{path} .git/hooks/pre-commit',
             git_commit:          'git commit %{git_commit_opts} -q %{git_commit_msg_opts}',
             git_show:            'git show --stat-count=10 HEAD',
             git_push:            'git push%{git_push_opts} --quiet "%{remote_url}" "%{target_branch}":"%{target_branch}" > /dev/null 2>&1'

        errs copy_files:          'Failed to copy %{src_dir}.',
             check_deploy_key:    'Failed to authenticate using the deploy key',
             git_init:            'Failed to create new git repo',
             git_checkout:        'Failed to create the orphan branch',
             git_push:            'Failed to push the build to %{url}:%{target_branch}'

        def login
          token? ? login_token : setup_deploy_key
        end

        def setup
          info :setup_dir, src_dir
          info :target_dir, dst_dir
          info :committer_from_gh if committer_from_gh?
          info :git_config
        end

        def prepare
          info :deploy
          info :keep_history if keep_history?
          debug :work_dir
          Dir.chdir(work_dir)
        end

        def deploy
          git_clone? ? git_clone : git_init
          copy_files
          return info :stop if git_clone? && !git_dirty?
          git_config
          git_commit
          git_push
          git_status if verbose?
        end

        private

        def login_token
          user.login
          info :login, user.login
          error :insufficient_scopes unless sufficient_scopes?
        rescue Octokit::Unauthorized => e
          error :invalid_token, e.message
        end

        def setup_deploy_key
          path = '~/.dpl/deploy_key'
          info :setup_deploy_key, path: path
          mv deploy_key, path
          chmod 0600, path
          setup_git_ssh path
          shell :check_deploy_key, key: path
        end

        def git_clone?
          keep_history? && git_branch_exists?
        end

        def git_clone
          shell :git_clone, echo: false
        end

        def git_init
          shell :git_init
          shell :git_checkout
        end

        def copy_files
          shell :copy_files
        end

        def git_config
          shell :git_config_name, echo: false
          shell :git_config_email, echo: false
        end

        def git_commit
          info :prepare
          shell :git_commit_hook, path: asset(:git, :detect_private_key).path, echo: false if deploy_key?
          shell :deployment_file if deployment_file?
          shell :cname if fqdn?
          shell :git_add
          shell :git_commit
          shell :git_show
        end

        def git_push
          shell :git_push, echo: false
        end

        def git_status
          shell 'git status'
        end

        def git_branch_exists?
          git_ls_remote?(remote_url, target_branch)
        end

        def git_commit_opts
          ' --allow-empty' if allow_empty_commit?
        end

        def git_commit_msg_opts
          msg = interpolate(commit_message, vars: vars)
          msg.split("\n").reject(&:empty?).map { |msg| %(-m #{quote(msg)}) }
        end

        def git_push_opts
          ' --force' unless keep_history?
        end

        def name
          str = super if name?
          str ||= user.name if committer_from_gh?
          str ||= git_author_name
          str = "#{str} (via Travis CI)" if ENV['TRAVIS'] && !name?
          str
        end
        memoize :name

        def email
          str = super if email?
          str ||= user.email if committer_from_gh?
          str || git_author_email
        end
        memoize :email

        def project_name
          super || fqdn || repo_slug
        end

        def sufficient_scopes?
          api.scopes.include?('public_repo') || api.scopes.include?('repo')
        end

        def remote_url
          token? ? https_url_with_token : git_url
        end

        def https_url_with_token
          "https://#{token}@#{url}"
        end

        def git_url
          "git@#{opts[:url]}:#{slug}.git"
        end

        def url
          "#{opts[:url]}/#{slug}.git"
        end

        def slug
          repo || repo_slug
        end

        def user
          @user ||= api.user
        end

        def src_dir
          @src_dir ||= expand(local_dir)
        end

        def dst_dir
          @dst_dir ||= target_dir
        end

        def work_dir
          @work_dir ||= tmp_dir
        end

        def api
          @api ||= Octokit::Client.new(access_token: token, api_endpoint: api_endpoint)
        end

        def api_endpoint
          opts[:url] == 'github.com' ? 'https://api.github.com/' : "https://#{opts[:url]}/api/v3/"
        end

        def now
          Time.now
        end

        def debug(*args)
          info *args if verbose?
        end
      end
    end
  end
end
