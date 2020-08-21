module Dpl
  module Providers
    class Netlify < Provider
      register :netlify

      status :stable

      description sq(<<-str)
        tbd
      str

      npm 'netlify-cli', 'netlify'

      env :netlify

      opt '--site ID',         'A site ID to deploy to', required: true
      opt '--auth TOKEN',      'An auth token to log in with', required: true, secret: true
      opt '--dir DIR',         'Specify a folder to deploy'
      opt '--functions FUNCS', 'Specify a functions folder to deploy'
      opt '--message MSG',     'A message to include in the deploy log'
      opt '--prod',            'Deploy to production'
      opt '--json',            'Output json data'

      def deploy
        output = shell "netlify deploy #{deploy_opts}", echo: false, capture:true
        info output
        if json
          shell "echo \"#{output.gsub(/\n/, '').gsub(/"/, '\"')}\" > ./NETLIFY_DEPLOY_JSON_ID_#{site}.json"
        end
      end

      private

        def deploy_opts
          opts_for(%i(site auth dir functions message prod json))
        end
    end
  end
end
