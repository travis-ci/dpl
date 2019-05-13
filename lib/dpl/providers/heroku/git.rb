require 'netrc'

module Dpl
  module Providers
    class Heroku
      class Git < Heroku
        needs :git_http_user_agent

        def prepare
          write_netrc if remote.start_with?('https://')
        end

        def deploy
          shell "git fetch origin $TRAVIS_BRANCH --unshallow", echo: true
          shell "git push #{remote} HEAD:refs/heads/master -f", echo: true
        end

        private

          def remote
            git || "https://git.heroku.com/#{app}.git"
          end

          def write_netrc
            netrc = Netrc.read
            netrc['git.heroku.com'] = [email, api_key || password]
            netrc.save
          end
      end
    end
  end
end
