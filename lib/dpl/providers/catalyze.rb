module Dpl
  module Providers
    class Catalyze < Provider
      env :catalyze

      opt '--target TARGET', 'The git remote repository to deploy to', required: true
      opt '--path PATH', 'Path to files to deploy', default: '.'

      CMDS = {
        git_push:     'git push --force %{target} HEAD:master',
        git_checkout: 'git checkout HEAD',
        git_add:      'git add %{path} --all --force',
        git_commit:   'git commit -m "%{message}" --quiet'
      }

      MSGS = {
        commit: 'Committing build files for deployment',
        deploy: 'Deploying to Catalyze: %{target}',
      }

      def setup
        commit if skip_cleanup?
      end

      def deploy
        info :deploy
        shell :git_push
      end

      private

        def commit
          info :commit
          shell :git_checkout
          shell :git_add
          shell :git_commit
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
