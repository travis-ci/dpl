module DPL
  class Provider
    class BuildBranch < Provider
      """Implements Github Build Branch deployment

      Options:
        - repo [optional, for pushed to other repos]
        - github-token [required]
        - target-branch [optional, defaults to build]
        - local-dir [optional, defaults to `pwd`]
        - project-name [optional, defaults to repo slug]
        - email [optional, defaults to deploy@travis-ci.org]
        - name [optional, defaults to Deployment Bot]
      """

      require 'tmpdir'

      experimental 'GitHub Build Branch'

      def initialize(context, options)
        super

        @build_dir = options[:local_dir] || '.'

        @project_name = options[:project_name] || slug

        @gh_ref = "github.com/#{slug}.git"
        @target_branch = options[:target_branch] || 'build'
        @gh_token = option(:github_token)

        @gh_email = options[:email] || 'deploy@travis-ci.org'
        @gh_name = "#{options[:name] || 'Deployment Bot'} (from Travis CI)"
      end

      def slug
        options.fetch(:repo) { context.env['TRAVIS_REPO_SLUG'] }
      end

      def check_auth
      end

      def needs_key?
        false
      end

      def github_deploy
        context.shell 'rm -rf .git > /dev/null 2>&1'
        context.shell 'git init' or raise 'Could not create new git repo'
        context.shell "git config user.email '#{@gh_email}'"
        context.shell "git config user.name '#{@gh_name}'"
        context.shell 'git add .'
        context.shell "git commit -m 'Deploy #{@project_name} to #{@gh_ref}:#{@target_branch}'"
        context.shell "git push --force --quiet 'https://#{@gh_token}@#{@gh_ref}' master:#{@target_branch} > /dev/null 2>&1"
      end

      def push_app
        Dir.mktmpdir {|tmpdir|
            FileUtils.cp_r("#{@build_dir}/.", tmpdir)
            FileUtils.cd(tmpdir, :verbose => true) do
              unless github_deploy
                error "Couldn't push the build to #{@gh_ref}:#{@target_branch}"
              end
            end
        }
      end

    end
  end
end
