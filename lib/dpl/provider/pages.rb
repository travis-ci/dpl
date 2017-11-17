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
        - verbose [optional, defaults to false]
        - local-dir [optional, defaults to `pwd`]
        - fqdn [optional]
        - project-name [optional, defaults to fqdn or repo slug]
        - email [optional, defaults to deploy@travis-ci.org]
        - name [optional, defaults to Deployment Bot]
      """

      require 'tmpdir'

      experimental 'GitHub Pages'

      def initialize(context, options)
        super

        @build_dir = options[:local_dir] || '.'
        @project_name = options[:project_name] || fqdn || slug
        @target_branch = options[:target_branch] || 'gh-pages'

        @gh_fqdn = fqdn
        @gh_url = options[:github_url] || 'github.com'
        @gh_token = option(:github_token)
        @keep_history = !!keep_history
        @allow_empty_commit = !!allow_empty_commit
        @verbose = !!verbose

        @gh_email = options[:email] || 'deploy@travis-ci.org'
        @gh_name = "#{options[:name] || 'Deployment Bot'} (from Travis CI)"

        @gh_ref = "#{@gh_url}/#{slug}.git"
        @gh_remote_url = "https://#{@gh_token}@#{@gh_ref}"
        @git_push_opts = @keep_history ? '' : ' --force'
        @git_commit_opts = (@allow_empty_commit and @keep_history) ? ' --allow-empty' : ''
      end

      def fqdn
        options.fetch(:fqdn) { nil }
      end

      def slug
        options.fetch(:repo) { context.env['TRAVIS_REPO_SLUG'] }
      end

      def keep_history
        options.fetch(:keep_history, false)
      end

      def allow_empty_commit
        options.fetch(:allow_empty_commit, false)
      end

      def verbose
        # Achtung! Never verbosify git, since it may expose user's token.
        options.fetch(:verbose, false)
      end

      def check_auth
      end

      def needs_key?
        false
      end

      def print_step(msg)
        log msg if @verbose
      end

      def github_pull(target_dir)
        print_step "Trying to clone a single branch #{@target_branch} from existing repo..."
        unless context.shell "git clone --quiet --branch='#{@target_branch}' --depth=1 '#{@gh_remote_url}' '#{target_dir}' &>/dev/null"
          # if such branch doesn't exist at remote, do normal clone and create
          # a new orphan branch
          print_step "Cloning #{@target_branch} branch failed"
          print_step 'Trying to clone the whole repo...'
          context.shell "git clone --quiet '#{@gh_remote_url}' '#{target_dir}' &>/dev/null" or raise "It looks the repo doesn't exist on remote or is inaccessible"
          FileUtils.cd(target_dir, :verbose => @verbose) do
            print_step "Assuming #{@target_branch} branch doesn't exist, thus creating orphan one"
            context.shell "git checkout --orphan '#{@target_branch}'"
          end
        end
      end

      def github_init
        print_step 'Creating a brand new local repo from scratch...'
        context.shell "git init" or raise 'Could not create new git repo'
        print_step 'Repo created successfully'
        context.shell "git checkout --orphan '#{@target_branch}'" or raise 'Could not create an orphan git branch'
        print_step "An orphan branch #{@target_branch} created successfully"
      end

      def github_configure
        print_step "Configuring git committer to be #{@gh_name} <#{@gh_email}>"
        context.shell "git config user.email '#{@gh_email}'"
        context.shell "git config user.name '#{@gh_name}'"
      end

      def github_commit
        print_step "Preparing to deploy #{@target_branch} branch to gh-pages"
        context.shell "touch \"deployed at `date` by #{@gh_name}\""
        context.shell "echo '#{@gh_fqdn}' > CNAME" if @gh_fqdn
        context.shell 'git add -A .'
        context.shell "git commit#{@git_commit_opts} -qm 'Deploy #{@project_name} to #{@gh_ref}:#{@target_branch}'"
        context.shell 'git show --stat-count=10 HEAD'
      end

      def github_deploy
        print_step "Doing the git push..."
        unless context.shell "git push#{@git_push_opts} --quiet '#{@gh_remote_url}' '#{@target_branch}':'#{@target_branch}' &>/dev/null"
          error "Couldn't push the build to #{@gh_ref}:#{@target_branch}"
        end
      end

      def push_app
        print_step "Starting deployment of #{@target_branch} branch to GitHub Pages..."
        print_step "The deployment is configured to preserve the target branch if it exists on remote" if @keep_history
        Dir.mktmpdir do |tmpdir|
            print_step "Created a temporary directory #{tmpdir}"

            if @keep_history
              github_pull(tmpdir)
            end

            print_step "Copying #{@build_dir} contents to #{tmpdir}..."
            context.shell "rsync -r --exclude .git --delete '#{@build_dir}/' '#{tmpdir}'" or error "Could not copy #{@build_dir}."

            unless @keep_history
              github_init
            end
            github_configure
            github_commit
            github_deploy
            context.shell "git status" if @verbose
        end
        print_step "App has been pushed"
      end

    end
  end
end
