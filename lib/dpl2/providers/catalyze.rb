module Dpl
  module Providers
    class Catalyze < Provider
      env :catalyze

      opt '--target TARGET', 'The git remote repository to deploy to', required: true
      opt '--path PATH', 'If using --skip_cleanup to deploy from current state, you can optionally specify path for the files to deploy. If not specified then all files are deployed.', default: '.'

      # fold deploy: 'Deploying to Catalyze: %{target}'

      def setup
        skip_cleanup if skip_cleanup?
      end

      def deploy
        shell "git push --force #{target} HEAD:master"
      end

      def skip_cleanup
        info 'Using build files for deployment'
        shell 'git checkout HEAD'
        shell "git add #{path} --all --force"
        shell %(git commit -m "#{message}" --quiet)
      end

      def message
        vars.empty? ? 'Local build' : 'Build #%s (%s) of %s@%s' % vars
      end

      VARS = %w(
        TRAVIS_BUILD_NUMBER
        TRAVIS_COMMIT
        TRAVIS_REPO_SLUG
        TRAVIS_BRANCH
      )

      def vars
        @vars ||= ENV.values_at(*VARS).compact
      end
    end
  end
end
