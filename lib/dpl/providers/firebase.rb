module Dpl
  module Providers
    class Firebase < Provider
      description sq(<<-str)
        tbd
      str

      node_js '>= 8.0.0'

      npm 'firebase-tools@^6.3', 'firebase'

      env :firebase

      opt '--token TOKEN',   'Firebase CI access token (generate with firebase login:ci)', required: true, secret: true
      opt '--project NAME',  'Firebase project to deploy to (defaults to the one specified in your firebase.json)'
      opt '--message MSG',   'Message describing this deployment.'
      opt '--only SERVICES', 'Firebase services to deploy'

      cmds deploy: 'firebase deploy --non-interactive %{deploy_opts}'
      errs deploy: 'Firebase deployment failed'
      msgs missing_config: 'Missing firebase.json'

      def validate
        error :missing_config unless File.exists?('firebase.json')
      end

      def deploy
        shell :deploy
      end

      def deploy_opts
        opts_for(%i(project message token only))
      end
    end
  end
end
