module Dpl
  module Providers
    class Heroku
      class Git < Heroku
        gem 'faraday', '~> 0.15.4'
        gem 'rendezvous', '~> 0.1.3'
        gem 'netrc', '~> 0.11.0'

        full_name 'Heroku Git'

        description sq(<<-str)
          tbd
        str

        # according to the docs it should be --username, but the code uses --user
        # https://github.com/travis-ci/dpl/blob/master/lib/dpl/provider/heroku/generic.rb#L20
        required :api_key, [:username, :password]

        # readme says username/password are allowed, but the code does not seem to
        # use them for writing the netrc https://github.com/travis-ci/dpl/blob/master/lib/dpl/provider/heroku/git.rb
        # so the api key is required in any case?
        opt '--api_key KEY',   'Heroku API key'
        opt '--username USER', 'Heroku username', alias: :user
        opt '--password PASS', 'Heroku password'
        # mentioned in the code
        opt '--git URL'

        needs :git, :git_http_user_agent

        cmds fetch: 'git fetch origin $TRAVIS_BRANCH --unshallow',
             push:  'git push %{remote} HEAD:refs/heads/master -f'

        def prepare
          write_netrc if write_netrc?
        end

        def deploy
          shell :fetch, echo: true
          shell :push, echo: true
        end

        private

          def remote
            git || "https://git.heroku.com/#{app}.git"
          end

          def write_netrc?
            remote.start_with?('https://')
          end

          def write_netrc
            super('git.heroku.com', email, api_key || password)
          end
      end
    end
  end
end
