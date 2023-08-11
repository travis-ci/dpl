# frozen_string_literal: true

module Dpl
  module Providers
    class Flynn < Provider
      register :flynn

      status :dev

      full_name 'Flynn'

      description sq(<<-STR)
        Flynn provider for Dpl
      STR

      opt '--git URL', 'Flynn Git remote URL', required: true

      needs :git, :git_http_user_agent

      cmds fetch: 'git fetch origin $TRAVIS_BRANCH --unshallow',
           push: 'git push %{remote} HEAD:refs/heads/master -f'

      def deploy
        shell :fetch, assert: false
        shell :push
      end

      private

      def remote
        git
      end
    end
  end
end
