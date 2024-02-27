# frozen_string_literal: true

module Dpl
  module Providers
    class Heroku
      class Git < Heroku
        register :'heroku:git'

        status :alpha

        full_name 'Heroku Git'

        description sq(<<-STR)
          tbd
        STR

        required :api_key, %i[username password]

        opt '--api_key KEY',   'Heroku API key', secret: true
        opt '--username USER', 'Heroku username', alias: :user
        opt '--password PASS', 'Heroku password', secret: true
        opt '--git URL', 'Heroku Git remote URL'

        needs :git, :git_http_user_agent

        cmds fetch: 'git fetch origin $TRAVIS_BRANCH --unshallow',
             push: 'git push %{remote} HEAD:refs/heads/master -f'

        def prepare
          write_netrc if write_netrc?
        end

        def deploy
          shell :fetch, assert: false
          shell :push
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
