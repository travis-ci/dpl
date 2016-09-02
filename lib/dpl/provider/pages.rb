module DPL
  class Provider
    class Pages < Provider
      """Implements Github Pages deployment

      Options:
        - repo [optional, for pushed to other repos]
        - github-token [required]
        - target-branch [optional, defaults to gh-pages]
        - local-dir [optional, defaults to `pwd`]
        - fqdn [optional]
        - project-name [optional, defaults to fqdn or repo slug]
        - email [optional]
        - name [optional]
      """

      def initialize(context, options)
        super

        @build_dir = options[:local_dir] || '.'

        @project_name = options[:project_name] || fqdn || slug
        @gh_fqdn = fqdn

        @gh_ref = "github.com/#{slug}.git"
        @target_branch = options[:target_branch] || 'gh-pages'
        @gh_token = option(:github_token)

        @gh_email = options[:email] || 'deploy@travis-ci.org'
        @gh_name = "#{options[:name] || 'Deployment Bot'} (from Travis CI)"
      end

      def fqdn
        options.fetch(:fqdn) { nil }
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
        context.shell "touch \"deployed by #{@gh_name} at `date`\""
        context.shell 'git init' or raise 'Could not create new git repo'
        context.shell "git config user.email '#{@gh_email}'"
        context.shell "git config user.name '#{@gh_name}'"
        context.shell "echo '#{@gh_fqdn}' > CNAME" if @gh_fqdn
        context.shell 'git add .'
        context.shell "git commit -m 'Deploy #{@project_name} to #{@gh_ref}:#{@target_branch}'"
        context.shell "git push --force --quiet 'https://#{@gh_token}@#{@gh_ref}' master:#{@target_branch} > /dev/null 2>&1"
      end

      def push_app
        FileUtils.cd(@build_dir, :verbose => true) do
          unless github_deploy
            error "Couldn't push the build to #{@gh_ref}:#{@target_branch}"
          end
        end
      end

    end
  end
end
