module Dpl
  module Providers
    class Netlify < Provider
      npm 'netlify-cli', 'netlify'

      description sq(<<-str)
        tbd
      str

      opt '--auth TOKEN',      'An auth token to log in with', required: true
      opt '--site ID',         'A site ID to deploy to', required: true
      opt '--dir DIR',         'Specify a folder to deploy'
      opt '--functions FUNCS', 'Specify a functions folder to deploy'
      opt '--message MSG',     'A message to include in the deploy log'
      opt '--prod',            'Deploy to production'

      def deploy
        shell "netlify deploy #{deploy_opts}"
      end

      private

        def deploy_opts
          opts_for(%i(site auth dir functions message prod))
        end
    end
  end
end
