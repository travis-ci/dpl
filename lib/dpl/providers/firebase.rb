module Dpl
  module Providers
    class Firebase < Provider
      register :firebase

      status :stable

      description sq(<<-str)
        tbd
      str

      node_js '>= 10.13.0'

      npm 'firebase-tools@^9.16', 'firebase'

      path 'node_modules/.bin'

      env :firebase

      opt '--token TOKEN',   'Firebase CI access token (generate with firebase login:ci)', required: true, secret: true
      opt '--project NAME',  'Firebase project to deploy to (defaults to the one specified in your firebase.json)'
      opt '--message MSG',   'Message describing this deployment.'
      opt '--only SERVICES', 'Firebase services to deploy', note: 'can be a comma-separated list'
      opt '--except SERVICES', 'Firebase services to not deploy', note: 'can be a comma-separated list'
      opt '--public PATH',   'Override the Hosting public directory specified in firebase.json'
      opt '--force',         'Whether or not to delete Cloud Functions missing from the current working directory'

      cmds deploy: 'firebase deploy %{deploy_opts}'
      errs deploy: 'Firebase deployment failed'
      msgs missing_config: 'Missing firebase.json'

      def validate
        error :missing_config unless File.exists?('firebase.json')
      end

      def deploy
        shell :deploy
      end

      def deploy_opts
        opts_for(%i(project message token only except public force))
      end
    end
  end
end
