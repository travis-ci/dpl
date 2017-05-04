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

      def github_clean
        print_step 'Purging every existing file from repo...'
        context.shell "git ls-files -z 2>/dev/null | xargs -0 rm -f 2>/dev/null"  # remove all committed files from the repo
        print_step 'Cleaning up all folders from repo...'
        context.shell "git ls-tree --name-only -d -r -z HEAD 2>/dev/null | sort -rz | xargs -0 rmdir 2>/dev/null"  # remove all directories from the repo
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
        context.shell "FILES=\"`git commit#{@git_commit_opts} -m 'Deploy #{@project_name} to #{@gh_ref}:#{@target_branch}' | tail`\"; echo \"$FILES\"; echo \"$FILES\" | [ `wc -l` -lt 10 ] || echo '...'"
      end

      def github_deploy
        print_step "Doing the git push..."
        context.shell "git push#{@git_push_opts} --quiet '#{@gh_remote_url}' '#{@target_branch}':'#{@target_branch}' &>/dev/null"
      end

      def prepare_dir_tree(dir)
            build = "#{dir}/build"
            work = "#{dir}/work"

            Dir.mkdir(build)
            print_step "Created a temporary build directory #{build}"

            Dir.mkdir(work)
            print_step "Created a temporary working directory #{work}"

            return build, work
      end

      def prepare_build_dir(build, tmp)
            FileUtils.cp_r("#{build}/.", tmp)
            print_step "Copied over build contents to #{tmp}"
            FileUtils.cd(tmp, :verbose => @verbose) do
                FileUtils.rm_r '.git', :force => true, :verbose => @verbose # cleanup garbage
                print_step "Cleaned up .git artifacts"
            end
      end

      def push_app
        print_step "Starting deployment of #{@target_branch} branch to GitHub Pages..."
        print_step "The deployment is configured to preserve the target branch if it exists on remote" if @keep_history
        Dir.mktmpdir do |tmpdir|
            print_step "Created a temporary directory #{tmpdir}"

            tmp_build_dir, tmp_work_dir = prepare_dir_tree(tmpdir)

            prepare_build_dir(@build_dir, tmp_build_dir)

            if @keep_history
              github_pull(tmp_work_dir)
              FileUtils.cd(tmp_work_dir, :verbose => @verbose) do
                github_clean
              end
            end

            print_step "Copying #{@build_dir} contents to #{tmp_work_dir}..."
            FileUtils.cp_r("#{tmp_build_dir}/.", tmp_work_dir)

            print_step "Entering #{tmp_work_dir}..."
            FileUtils.cd(tmp_work_dir, :verbose => @verbose) do
              unless @keep_history
                github_init
              end
              github_configure
              github_commit
              unless github_deploy
                error "Couldn't push the build to #{@gh_ref}:#{@target_branch}"
              end
              context.shell "git status" if @verbose
            end
        end
        print_step "App has been pushed"
      end

    end
  end
end
