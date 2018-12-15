module DPL
  class Provider
    class Gleis < Provider
      def install_deploy_dependencies
        context.shell 'gem install gleis'
      end

      def needs_key?
        true
      end

      def check_auth
        error 'Login failed' unless context.shell "gleis auth login #{option(:username)} #{option(:password)} --skip-keygen"
      end

      def check_app
        error 'Application not found' unless context.shell "gleis app status -a #{option(:app)}"
      end

      def setup_key(file)
        error 'Adding key failed' unless context.shell "gleis auth key add #{file} dpl_#{option(:key_name)}"
      end

      def remove_key
        error 'Removing key failed' unless context.shell "gleis auth key remove dpl_#{option(:key_name)}"
      end

      def repository_url
        error 'Failed to get git repo URL' unless context.shell "gleis app git -a #{option(:app)} -q > .dpl/git-url"
        File.read('.dpl/git-url').chomp if File.exist?('.dpl/git-url')
      end

      def push_app
        git_url = repository_url
        error 'Git repo URL is empty' unless git_url
        error 'Deploying application failed' unless context.shell "git push #{verbose_flag} #{git_url} HEAD:refs/heads/master"
      end

      def cleanup; end

      def uncleanup
        context.shell 'gleis auth logout'
      end

      def verbose_flag
        '-v' if options[:verbose]
      end
    end
  end
end
