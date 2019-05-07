module Dpl
  module Providers
    class BluemixCloudFoundry < Provider
      summary 'Anynines deployment provider'

      description <<~str
        tbd
      str

      opt '--username USER',       'Bluemix username', required: true
      opt '--password PASS',       'Bluemix password', required: true
      opt '--organization ORG',    'Bluemix target organization', required: true
      opt '--space SPACE',         'Bluemix target space', required: true
      opt '--region REGION',       'Bluemix region (ng, eu-gb, eu-de, au-syd)', default: 'ng'
      opt '--api URL',             'Bluemix api URL'
      opt '--app_name APP',        'Application name'
      opt '--manifest FILE',       'Path to the manifest'
      opt '--skip_ssl_validation', 'Skip SSL validation'

      API = {
        'ng':     'api.ng.bluemix.net',
        'eu-gb':  'api.eu-gb.bluemix.net',
        'eu-de':  'api.eu-de.bluemix.net',
        'au-syd': 'api.au-syd.bluemix.net'
      }

      def install
        shell 'test $(uname) = "Linux" && rel="linux64-binary" || rel="macosx64"; wget "https://cli.run.pivotal.io/stable?release=${rel}&source=github" -qO cf.tgz && tar -zxvf cf.tgz && rm cf.tgz'
      end

      def check_auth
        shell "./cf api #{api} #{'--skip-ssl-validation' if skip_ssl_validation?}".strip
        shell "./cf login -u #{username} -p #{password} -o #{organization} -s #{space}"
      end

      def deploy
        shell "./cf push #{args}".strip, assert: 'Failed to push app'
      end

      def finish
        shell "./cf logout"
        super
      end

      def args
        args = []
        args << quote(app_name)  if app_name?
        args << "-f #{manifest}" if manifest?
        args.join(' ')
      end

      def api
        opts[:api] || API[region.to_sym]
      end
    end
  end
end
