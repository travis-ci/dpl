module DPL
  class Provider
    module Heroku
      class Git < Generic
        def git_url
          "https://git.heroku.com/#{option(:app)}.git"
        end

        def push_app
          git_remote = options[:git] || git_url
          write_netrc if git_remote.start_with?("https://")
          log "$ git fetch origin $TRAVIS_BRANCH --unshallow"
          context.shell "git fetch origin $TRAVIS_BRANCH --unshallow"
          log "$ git push #{git_remote} HEAD:refs/heads/master -f"
          context.shell "git push #{git_remote} HEAD:refs/heads/master -f"
        end

        def write_netrc
          n = Netrc.read
          n['git.heroku.com'] = [user, option(:api_key)]
          n.save
        end
      end
    end
  end
end
