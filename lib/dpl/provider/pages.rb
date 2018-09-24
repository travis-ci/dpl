require 'octokit'

module DPL
  class Provider
    class Pages < Provider
      """Implements Github Pages deployment

      Options:
        - repo [optional, for pushed to other repos]
        - github-token [required]
        - github-url [optional, defaults to github.com]
        - target-branch [optional, defaults to gh-pages]
        - keep-history [optional, defaults to false]
        - allow-empty-commit [optional, defaults to false]
        - committer-from-gh [optional, defaults to false]
        - verbose [optional, defaults to false]
        - local-dir [optional, defaults to `pwd`]
        - fqdn [optional]
        - project-name [optional, defaults to fqdn or repo slug]
        - email [optional, defaults to deploy@travis-ci.org]
        - name [optional, defaults to Deployment Bot]
        - deployment-file [optional, defaults to false]
      """

      require 'tmpdir'
      experimental 'GitHub Pages'

      def initialize(context, options)
        super

        @build_dir = File.join(src_dir, options[:local_dir] || '.')
        print_step "The target dir for deployment is '#{@build_dir}'."

        @project_name = options[:project_name] || fqdn || slug
        @target_branch = options[:target_branch] || 'gh-pages'

        @gh_fqdn = fqdn
        @gh_url = options[:github_url] || 'github.com'
        @keep_history = !!keep_history
        @allow_empty_commit = !!allow_empty_commit
        @committer_from_gh = !!committer_from_gh
        @verbose = !!verbose

        @gh_email = options[:email] || 'deploy@travis-ci.org'
        @gh_name = "#{options[:name] || 'Deployment Bot'} (from Travis CI)"

        @deployment_file = !!options[:deployment_file]

        @gh_ref = "#{@gh_url}/#{slug}.git"
        @git_push_opts = @keep_history ? '' : ' --force'
        @git_commit_opts = (@allow_empty_commit and @keep_history) ? ' --allow-empty' : ''

        print_step "The repo is configured to use committer user and email." if @committer_from_gh
      end

      def gh_token
        @gh_token ||= option(:github_token)
      end

      def gh_remote_url
        @gh_remote_url ||= "https://#{gh_token}@#{@gh_ref}"
      end

      def fqdn
        options.fetch(:fqdn) { nil }
      end

      def slug
        options.fetch(:repo) { context.env['TRAVIS_REPO_SLUG'] }
      end

      def src_dir
        context.env['TRAVIS_BUILD_DIR'] or Dir.pwd
      end

      def keep_history
        options.fetch(:keep_history, false)
      end

      def committer_from_gh
        options.fetch(:committer_from_gh, false)
      end

      def allow_empty_commit
        options.fetch(:allow_empty_commit, false)
      end

      def verbose
        # Achtung! Never verbosify git, since it may expose user's token.
        options.fetch(:verbose, false)
      end

      def api  # Borrowed from Releases provider
        error 'gh-token must be provided for Pages provider to work.' unless gh_token

        return @api if @api

        api_opts = { :access_token => gh_token }
        api_opts[:api_endpoint] = @gh_url == 'github.com' ? "https://api.github.com/" : "https://#{@gh_url}/api/v3/"

        @api = Octokit::Client.new(api_opts)
      end

      def user
        @user ||= api.user
      end

      def setup_auth
        user.login
      end

      def check_auth
        setup_auth

        unless api.scopes.include? 'public_repo' or api.scopes.include? 'repo'
          error "Dpl does not have permission to access #{@gh_url} using it. Make sure your token contains the repo or public_repo scope."
        end

        log "Logged in as @#{user.login} (#{user.name})"
      rescue Octokit::Unauthorized => exc
        error "gh-token is invalid. Details: #{exc}"
      end

      def needs_key?
        false
      end

      def print_step(msg)
        log msg if @verbose
      end

      def github_pull_or_init(target_dir)
        unless @keep_history
          github_init(target_dir)
          return
        end

        print_step "Trying to clone a single branch #{@target_branch} from existing repo..."
        unless context.shell "git clone --quiet --branch='#{@target_branch}' --depth=1 '#{gh_remote_url}' '#{target_dir}' > /dev/null 2>&1"
          # if such branch doesn't exist at remote, init it from scratch
          print_step "Cloning #{@target_branch} branch failed"
          Dir.mkdir(target_dir)  # Restore dir destroyed by failed `git clone`
          github_init(target_dir)
        end
      end

      def github_init(target_dir)
        FileUtils.cd(target_dir, :verbose => true) do
          print_step "Creating a brand new local repo from scratch in dir #{Dir.pwd}..."
          context.shell "git init" or raise 'Could not create new git repo'
          print_step 'Repo created successfully'
          context.shell "git checkout --orphan '#{@target_branch}'" or raise 'Could not create an orphan git branch'
          print_step "An orphan branch #{@target_branch} created successfully"
        end
      end

      def identify_preferred_committer
        if @committer_from_gh and gh_token
          return (user.name or @gh_name), (user.email or @gh_email)
        end
        return @gh_name, @gh_email
      end

      def github_configure
        committer_name, committer_email = identify_preferred_committer
        print_step "Configuring git committer to be #{committer_name} <#{committer_email}> (workdir: #{Dir.pwd})"
        context.shell "git config user.email '#{committer_email}'"
        context.shell "git config user.name '#{committer_name}'"
      end

      def github_commit
        committer_name, _ = identify_preferred_committer
        print_step "Preparing to deploy #{@target_branch} branch to gh-pages (workdir: #{Dir.pwd})"
        context.shell "touch \"deployed at `date` by #{committer_name}\"" if @deployment_file
        context.shell "echo '#{@gh_fqdn}' > CNAME" if @gh_fqdn
        context.shell 'git add -A .'
        context.shell "git commit#{@git_commit_opts} -qm 'Deploy #{@project_name} to #{@gh_ref}:#{@target_branch}'"
        context.shell 'git show --stat-count=10 HEAD'
      end

      def github_deploy
        print_step "Doing the git push (workdir: #{Dir.pwd})..."
        unless context.shell "git push#{@git_push_opts} --quiet '#{gh_remote_url}' '#{@target_branch}':'#{@target_branch}' > /dev/null 2>&1"
          error "Couldn't push the build to #{@gh_ref}:#{@target_branch}"
        end
      end

      def push_app
        print_step "Starting deployment of #{@target_branch} branch to GitHub Pages..."
        print_step "The deployment is configured to preserve the target branch if it exists on remote" if @keep_history
        Dir.mktmpdir do |tmpdir|
            workdir = "#{tmpdir}/work"
            Dir.mkdir(workdir)
            print_step "Created a temporary work directory #{workdir}"

            github_pull_or_init(workdir)

            FileUtils.cd(workdir, :verbose => true) do
              print_step "Copying #{@build_dir} contents to #{workdir} (workdir: #{Dir.pwd})..."
              context.shell "rsync -r --exclude .git --delete '#{@build_dir}/' '#{workdir}'" or error "Could not copy #{@build_dir}."

              github_configure
              github_commit
              github_deploy
              context.shell "git status" if @verbose
            end
        end
        print_step "App has been pushed"
      end

    end
  end
end
