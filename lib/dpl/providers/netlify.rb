# frozen_string_literal: true

module Dpl
  module Providers
    class Netlify < Provider
      register :netlify

      status :stable

      description sq(<<-STR)
        tbd
      STR

      node_js '>= 18.14.0'

      npm 'netlify-cli', 'netlify'

      env :netlify

      opt '--site ID',         'A site ID to deploy to', required: true
      opt '--auth TOKEN',      'An auth token to log in with', required: true, secret: true
      opt '--dir DIR',         'Specify a folder to deploy'
      opt '--functions FUNCS', 'Specify a functions folder to deploy'
      opt '--message MSG',     'A message to include in the deploy log'
      opt '--prod',            'Deploy to production'

      def deploy
        shell "netlify deploy #{deploy_opts}"
      end

      private

      def deploy_opts
        opts_for(%i[site auth dir functions message prod])
      end
    end
  end
end
