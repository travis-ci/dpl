module DPL
  class Provider
    class Catalyze < Provider
      def config
        {
            # the git repository to deploy to
            "target" => options[:target] || context.env['CATALYZE_TARGET'],
            # the pathspec for files to add to git for deployment e.g. your build directory. defaults to all files.
            "path" => options[:path] || context.env['CATALYZE_PATH'] || '.'
        }
      end

      def needs_key?
        false
      end

      def check_app
      end

      def check_auth
        error "Missing Catalyze target" unless config['target']
      end

      def push_app
        log "Deploying to Catalyze '#{config['target']}'"

        if options[:skip_cleanup]
          # create commit message
          build_num = context.env["TRAVIS_BUILD_NUMBER"]
          commit = context.env["TRAVIS_COMMIT"]
          repo_slug = context.env["TRAVIS_REPO_SLUG"]
          branch = context.env["TRAVIS_BRANCH"]
          if build_num && commit && repo_slug && branch
            commit_message = "Build ##{build_num} (#{commit}) of #{repo_slug}@#{branch}"
          else
            commit_message = "Local build"
          end

          log "Using build files for deployment"
          context.shell "git checkout HEAD"
          context.shell "git add #{config["path"]} --all --force"
          context.shell "git commit -m \"#{commit_message}\" --quiet"
        end

        context.shell "git push --force #{config['target']} HEAD:master"
      end
    end
  end
end
