# frozen_string_literal: true

module Dpl
  module Providers
    class GitPush < Provider
      register :git_push

      status :dev

      full_name 'Git (push)'

      description sq(<<-STR)
        Experimental, generic provider for updating a Git remote branch with
        changes produced by the build, and optionally opening a pull request.
      STR

      gem 'octokit', '~> 7'
      gem 'public_suffix', '~> 5'

      env :github, :git

      required :token, %i[deploy_key name email]

      opt '--repo SLUG', 'Repo slug', default: :repo_slug
      opt '--token TOKEN', 'GitHub token with repo permission', secret: true, alias: :github_token
      opt '--deploy_key PATH', 'Path to a file containing a private deploy key with write access to the repository', see: 'https://developer.github.com/v3/guides/managing-deploy-keys/#deploy-keys'
      opt '--branch BRANCH', 'Target branch to push to', required: true
      opt '--base_branch BRANCH', 'Base branch to branch off initially, and (optionally) create a pull request for', default: 'master'
      opt '--name NAME', 'Committer name', note: 'defaults to the GitHub name or login associated with the GitHub token' # , default: :user_name
      opt '--email EMAIL', 'Committer email', note: 'defaults to the GitHub email associated with the GitHub token' # , default: :user_email
      opt '--commit_message MSG', default: 'Update %{base_branch}', interpolate: true
      opt '--allow_empty_commit', 'Allow an empty commit to be created'
      opt '--force', 'Whether to push --force', default: false
      opt '--local_dir DIR', 'Local directory to push', default: '.'
      opt '--pull_request', 'Whether to create a pull request for the given branch'
      opt '--allow_same_branch', 'Whether to allow pushing to the same branch as the current branch', default: false, note: 'setting this to true risks creating infinite build loops, use conditional builds or other mechanisms to prevent build from infinitely triggering more builds'
      opt '--host HOST', default: 'github.com'
      opt '--enterprise', 'Whether to use a GitHub Enterprise API style URL'

      needs :git

      msgs login: 'Authenticated as %s',
           invalid_token: 'The provided GitHub token is invalid (error: %s)',
           insufficient_scopes: 'Dpl does not have permission to access %{url} using the provided GitHub token. Please make sure the token have the repo or public_repo scope.',
           same_branch: 'Prevented from pushing to the same branch as the current build branch %{git_branch}. This is meant to prevent infinite build loops. If you do need to push back to the same branch enable `allow_same_branch` and take precautions to prevent infinite loops as needed, for example using conditional builds.',
           setup_deploy_key: 'Moving deploy key %{deploy_key} to %{path}',
           check_deploy_key: 'Checking deploy key',
           setup: 'Source dir: %{src_dir}, branch: %{branch}, base branch: %{base_branch}',
           git_clone: 'Cloning the branch %{branch} to %{work_dir}',
           git_branch: 'Switching to branch %{branch}',
           copy_files: 'Copying %{src_dir} contents to %{work_dir}',
           git_config: 'Configuring git committer to be: %{name} <%{email}>',
           git_push: 'Pushing to %{url} HEAD:%{branch}',
           pr_exists: 'Pull request exists.',
           pr_created: 'Pull request #%{number} created.',
           stop: 'There are no changes to commit, stopping.'

      cmds git_clone: 'git clone --quiet --branch="%{clone_branch}" "%{remote_url}" . > /dev/null 2>&1',
           git_branch: 'git checkout -b "%{branch}"',
           check_deploy_key: 'ssh -i %{key} -T git@github.com 2>&1 | grep successful > /dev/null',
           copy_files: 'rsync -rl --exclude .git --delete "%{src_dir}/" .',
           git_config_email: 'git config user.email %{quoted_email}',
           git_config_name: 'git config user.name %{quoted_name}',
           git_add: 'git add -A .',
           git_commit_hook: 'cp %{path} .git/hooks/pre-commit',
           git_commit: 'git commit %{git_commit_opts} -q %{git_commit_msg_opts}',
           git_show: 'git show --stat-count=10 HEAD',
           git_push: 'git push %{git_push_opts} --quiet "%{remote_url}" HEAD:"%{branch}" > /dev/null 2>&1'

      errs copy_files: 'Failed to copy %{src_dir}.',
           check_deploy_key: 'Failed to authenticate using the deploy key',
           git_init: 'Failed to create new git repo',
           git_push: 'Failed to push the build to %{url}:%{branch}'

      def validate
        error :same_branch if same_branch? && !allow_same_branch?
      end

      def setup
        info :setup
        info :git_config
      end

      def login
        token? ? login_token : setup_deploy_key
      end

      def prepare
        Dir.chdir(work_dir)
      end

      def deploy
        git_clone
        copy_files
        return info :stop unless git_dirty?

        push
        pull_request if pull_request?
      end

      def push
        git_config
        git_commit
        git_push
      end

      def pull_request
        pr_exists? ? info(:pr_exists) : create_pr
      end

      private

      def same_branch?
        git_branch == branch
      end

      def login_token
        return unless github?

        info :login, user.login
        error :insufficient_scopes unless sufficient_scopes?
      rescue Octokit::Unauthorized => e
        error :invalid_token, e.message
      end

      def setup_deploy_key
        path = '~/.dpl/deploy_key'
        info(:setup_deploy_key, path:)
        mv deploy_key, path
        chmod 0o600, path
        setup_git_ssh path
        shell :check_deploy_key, key: path
      end

      def git_clone
        shell :git_clone, echo: false
        shell :git_branch unless branch_exists?
      end

      def clone_branch
        branch_exists? ? branch : base_branch
      end

      def copy_files
        shell :copy_files
      end

      def git_config
        shell :git_config_name, echo: false
        shell :git_config_email, echo: false
      end

      def branch_exists?
        git_ls_remote?(remote_url, branch)
      end

      def git_commit
        shell :git_commit_hook, path: asset(:git, :detect_private_key).path, echo: false if deploy_key?
        shell :git_add
        shell :git_commit
        shell :git_show
      end

      def git_push
        shell :git_push, echo: false
      end

      def git_push_opts
        '--force' if force?
      end

      def git_commit_opts
        ' --allow-empty' if allow_empty_commit?
      end

      def git_commit_msg_opts
        msg = interpolate(commit_message, vars:)
        msg.split("\n").reject(&:empty?).map { |message| %(-m #{quote(message)}) }
      end

      def name
        str = super if name?
        str ||= user_name
        str = "#{str} (via Travis CI)" if ENV['TRAVIS'] && !name?
        str
      end
      memoize :name

      def email
        str = super if email?
        str || user_email
      end
      memoize :email

      def project_name
        super || repo_slug
      end

      def remote_url
        token? ? https_url_with_token : git_url
      end

      def https_url_with_token
        "https://#{token}@#{url}"
      end

      def git_url
        "git@#{host}:#{slug}.git"
      end

      def url
        "#{host}/#{slug}.git"
      end

      def slug
        repo || repo_slug
      end

      def src_dir
        @src_dir ||= expand(local_dir)
      end

      def work_dir
        @work_dir ||= tmp_dir
      end

      def sufficient_scopes?
        scopes.include?('public_repo') || scopes.include?('repo')
      end

      def user
        @user ||= github.user
      end

      def user_name
        user.name || user.login
      end

      def user_email
        user.email
      end

      def scopes
        @scopes ||= github.scopes
      end

      def pr_exists?
        !!github.pulls(repo).detect { |pull| pull.head.ref == branch }
      end

      def create_pr
        pr = github.create_pull_request(repo, base_branch, branch, "Update #{base_branch}")
        info :pr_created, number: pr.number
      end

      def github?
        host.include?('github') || enterprise?
      end

      def github
        @github ||= Octokit::Client.new(access_token: token, api_endpoint: api_url, auto_paginate: true)
      end

      def api_url
        enterprise? ? "https://#{host}/api/v3/" : 'https://api.github.com/'
      end

      def now
        Time.now
      end
    end
  end
end
