module Dpl
  module Providers
    class Firebase < Provider
      summary 'Firebase deployment provider'

      description <<~str
        tbd
      str

      env :firebase

      npm 'firebase-tools@^6.3', 'firebase'

      opt '--token TOKEN',  'Firebase CI access token (generate with firebase login:ci)', required: true
      opt '--project NAME', 'Firebase project to deploy to (defaults to the one specified in your firebase.json)'
      opt '--message MSG',  'Message describing this deployment.'

      CMDS = {
        deploy: 'firebase deploy --non-interactive %{deploy_opts}'
      }

      ASSERT = {
        deploy: 'Firebase deployment failed'
      }

      MSGS = {
        missing_config: 'Missing firebase.json'
      }

      def validate
        error :missing_config unless exists?('firebase.json')
      end

      def deploy
        shell :deploy, assert: true
      end

      def deploy_opts
        opts_for(%i(project message token))
      end
    end
  end
end
