module Dpl
  module Providers
    class Bluemixcloudfoundry < Provider
      register :bluemixcloudfoundry

      status :stable

      full_name 'Bluemix Cloud Foundry'

      description sq(<<-str)
        tbd
      str

      env :cloudfoundry

      opt '--username USER',       'Bluemix username', required: true
      opt '--password PASS',       'Bluemix password', required: true, secret: true
      opt '--organization ORG',    'Bluemix organization', required: true
      opt '--space SPACE',         'Bluemix space', required: true
      opt '--region REGION',       'Bluemix region', default: 'ng', enum: %w(ng eu-gb eu-de au-syd)
      opt '--api URL',             'Bluemix api URL'
      opt '--app_name APP',        'Application name'
      opt '--buildpack PACK',      'Buildpack name or Git URL'
      opt '--manifest FILE',       'Path to the manifest'
      opt '--skip_ssl_validation', 'Skip SSL validation'
      opt '--logout', default: true, internal: true

      API = {
        'ng':     'api.ng.bluemix.net',
        'eu-gb':  'api.eu-gb.bluemix.net',
        'eu-de':  'api.eu-de.bluemix.net',
        'au-syd': 'api.au-syd.bluemix.net'
      }

      cmds install: 'test $(uname) = "Linux" && rel="linux64-binary" || rel="macosx64"; wget "https://cli.run.pivotal.io/stable?release=${rel}&source=github" -qO cf.tgz && tar -zxvf cf.tgz && rm cf.tgz',
           api:     './cf api %{api} %{skip_ssl_validation_opt}',
           login:   './cf login -u %{username} -p %{password} -o "%{organization}" -s "%{space}"',
           target:  './cf target -o "%{organization}" -s "%{space}"',
           push:    './cf push %{push_args}',
           logout:  './cf logout'

      errs install: 'Failed to install CLI tools',
           api:     'Failed to set api %{api}',
           login:   'Failed to login',
           target:  'Failed to target organization %{organization}, space %{space}',
           push:    'Failed to push app',
           logout:  'Failed to logout'

      msgs manifest_missing: 'Application must have a manifest.yml for unattended deployment'

      def install
        shell :install
      end

      def validate
        error :manifest_missing if manifest? && manifest_missing?
      end

      def login
        shell :api
        shell :login
        shell :target
      end

      def deploy
        shell :push
      end

      def finish
        shell :logout if logout?
      end

      private

        def push_args
          args = []
          args << quote(app_name)  if app_name?
          args << "-f #{manifest}" if manifest?
          args << "-b #{buildpack}" if buildpack?
          args.join(' ')
        end

        def skip_ssl_validation_opt
          '--skip-ssl-validation' if skip_ssl_validation?
        end

        def manifest_missing?
          !File.exists?(manifest)
        end

        def api
          super || API[region.to_sym]
        end
    end
  end
end
