module DPL
  class Provider
    module Heroku
      class Git < Generic
        def git_url
          "https://#{option(:api_key)}@git.heroku.com/#{option(:app)}.git"
        end

        def push_app
          git_remote = options[:git] || git_url
          context.shell "git push #{git_remote} HEAD:refs/heads/master -f"
        end
      end
    end
  end
end
