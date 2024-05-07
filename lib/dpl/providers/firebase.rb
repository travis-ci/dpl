# frozen_string_literal: true

module Dpl
  module Providers
    class Firebase < Provider
      register :firebase

      status :stable

      description sq(<<-STR)
        tbd
      STR

      node_js '>= 8.0.0'

      npm 'firebase-tools@^6.3', 'firebase'

      path 'node_modules/.bin'

      env :firebase

      opt '--token TOKEN',   'Firebase CI access token (generate with firebase login:ci)', required: true, secret: true
      opt '--project NAME',  'Firebase project to deploy to (defaults to the one specified in your firebase.json)'
      opt '--message MSG',   'Message describing this deployment.'
      opt '--only SERVICES', 'Firebase services to deploy', note: 'can be a comma-separated list'
      opt '--force',         'Whether or not to delete Cloud Functions missing from the current working directory'

      cmds deploy: 'firebase deploy --non-interactive %{deploy_opts}'
      errs deploy: 'Firebase deployment failed'
      msgs missing_config: 'Missing firebase.json'

      def validate
        error :missing_config unless File.exist?('firebase.json')
      end

      def deploy
        shell :deploy
      end

      def deploy_opts
        opts_for(%i[project message token only force])
      end
    end
  end
end
